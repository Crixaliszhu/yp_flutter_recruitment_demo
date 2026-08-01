import 'package:dio/dio.dart';

import 'api_result.dart';
import 'mock_api_transport.dart';

typedef TokenProvider = Future<String?> Function();

/// 网络访问门面。
///
/// 业务域只能通过 Repository 间接使用它。这里保留 Dio 的配置能力，同时用
/// MockApiTransport 返回本地数据，方便演示架构而不依赖真实后端。
class ApiClient {
  ApiClient({required String baseUrl, required this.tokenProvider})
    : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;
  final TokenProvider tokenProvider;
  final MockApiTransport _mockTransport = const MockApiTransport();

  /// 获取 JSON 对象并统一包成 ApiResult。
  ///
  /// 真实项目中可以把 `_mockTransport.get` 替换为 `_dio.get`，调用方不需要改变。
  Future<ApiResult<Map<String, Object?>>> getJson(String path) async {
    try {
      final headers = await _resolveHeaders(path);
      final payload = await _mockTransport.get(path, headers: headers);
      return ApiResult.success(payload);
    } on Object catch (error, stackTrace) {
      return ApiResult.failure(error, stackTrace);
    }
  }

  /// 统一处理请求头。
  ///
  /// token、客户端标识、灰度实验参数、追踪 id 等横切信息都适合放在这一层。
  Future<Map<String, Object?>> _resolveHeaders(String path) async {
    final requestOptions = RequestOptions(
      path: path,
      baseUrl: _dio.options.baseUrl,
    );
    final token = await tokenProvider();
    if (token != null && token.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }
    requestOptions.headers['X-Client'] = 'pure-flutter-demo';
    return requestOptions.headers.cast<String, Object?>();
  }
}
