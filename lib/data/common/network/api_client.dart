import 'package:dio/dio.dart';

import 'api_result.dart';
import 'mock_api_transport.dart';
import 'network_error_toast_interceptor.dart';
import 'network_loading_controller.dart';
import 'network_loading_interceptor.dart';

typedef TokenProvider = Future<String?> Function();
typedef ApiDecoder<T> = T Function(Object? json);

/// Data 层使用的网络门面。
///
/// 统一封装 Dio 的 GET/POST、通用请求头、接口额外请求头、loading 拦截器和错误映射。
class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.tokenProvider,
    required NetworkLoadingController loadingController,
  }) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.httpClientAdapter = const MockDioAdapter(MockApiTransport());
    _dio.interceptors.add(_buildCommonHeaderInterceptor());
    _dio.interceptors.add(NetworkLoadingInterceptor(loadingController));
    _dio.interceptors.add(NetworkErrorToastInterceptor());
  }

  final Dio _dio;
  final TokenProvider tokenProvider;

  /// GET 请求，支持 query、额外 header 和 loading 开关。
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    bool showLoading = true,
    bool allowErrorToast = true,
    ApiDecoder<T>? decoder,
  }) {
    return _request<T>(
      () => _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: _buildOptions(
          headers: headers,
          showLoading: showLoading,
          allowErrorToast: allowErrorToast,
        ),
      ),
      decoder: decoder,
    );
  }

  /// POST 请求，支持 body、query、额外 header 和 loading 开关。
  Future<ApiResult<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    bool showLoading = true,
    bool allowErrorToast = true,
    ApiDecoder<T>? decoder,
  }) {
    return _request<T>(
      () => _dio.post<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(
          headers: headers,
          showLoading: showLoading,
          allowErrorToast: allowErrorToast,
        ),
      ),
      decoder: decoder,
    );
  }

  /// 获取 JSON 对象，保留给当前 demo 的 DS 层使用。
  Future<ApiResult<Map<String, Object?>>> getJson(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    bool showLoading = true,
    bool allowErrorToast = true,
  }) {
    return get<Map<String, Object?>>(
      path,
      queryParameters: queryParameters,
      headers: headers,
      showLoading: showLoading,
      allowErrorToast: allowErrorToast,
      decoder: _asJsonMap,
    );
  }

  /// 提交 JSON 对象，保留给当前 demo 的 DS 层使用。
  Future<ApiResult<Map<String, Object?>>> postJson(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    bool showLoading = true,
    bool allowErrorToast = true,
  }) {
    return post<Map<String, Object?>>(
      path,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      showLoading: showLoading,
      allowErrorToast: allowErrorToast,
      decoder: _asJsonMap,
    );
  }

  Options _buildOptions({
    Map<String, Object?>? headers,
    required bool showLoading,
    required bool allowErrorToast,
  }) {
    return Options(
      headers: headers,
      extra: {
        NetworkLoadingInterceptor.showLoadingKey: showLoading,
        NetworkErrorToastInterceptor.allowErrorToastKey: allowErrorToast,
      },
    );
  }

  Interceptor _buildCommonHeaderInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenProvider();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['X-Client'] = 'pure-flutter-demo';
        options.headers['X-Trace-Id'] =
            DateTime.now().microsecondsSinceEpoch.toString();
        handler.next(options);
      },
    );
  }

  Future<ApiResult<T>> _request<T>(
    Future<Response<Object?>> Function() request, {
    ApiDecoder<T>? decoder,
  }) async {
    try {
      final response = await request();

      if (response.statusCode == 200) {
        final data =
            decoder == null ? response.data as T? : decoder(response.data);
        return ApiSuccess.buildSuccess<T>(
          data,
          response.statusMessage,
          response.headers.value('x-ask-id') ?? '',
        );
      }
      return ApiFail.buildFail(
        response.statusMessage,
        '',
        response.statusCode,
        null,
      );
    } on DioException catch (error) {
      return _buildDioFail<T>(error);
    } on Object catch (error) {
      return ApiFail.buildFail<T>(error.toString(), '', -1, null);
    }
  }

  ApiResult<T> _buildDioFail<T>(DioException error) {
    final response = error.response;
    return ApiFail.buildFail<T>(
      error.message ?? '网络请求失败',
      response?.headers.value('x-ask-id') ?? '',
      response?.statusCode ?? -1,
      null,
    );
  }

  Map<String, Object?> _asJsonMap(Object? json) {
    if (json is Map<String, Object?>) {
      return json;
    }
    if (json is Map) {
      return json.cast<String, Object?>();
    }
    throw StateError('接口返回不是 JSON 对象：$json');
  }
}
