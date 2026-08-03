import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 本地 mock 传输层。
///
/// 它让 demo 保持接近真实网络调用的形态，同时不依赖后端服务。
class MockApiTransport {
  const MockApiTransport();

  Future<Map<String, Object?>> get(
    String path, {
    required Map<String, Object?> headers,
    Map<String, Object?>? queryParameters,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final authed = headers['Authorization']?.toString().isNotEmpty ?? false;

    return switch (path) {
      '/launch/config' => {
        'enableSplashAd': true,
        'minShowMillis': 900,
        'targetPath': '/home',
        'authed': authed,
      },
      '/home/summary' => {
        'title': '首页工作台',
        'description': '聚合推荐职位、待办跟进、最近沟通，像 recruitment_android 的 main/yupao 域。',
        'badges': ['推荐职位 18', '待跟进 4', '同城急招 7'],
        'authed': authed,
      },
      '/market/summary' => {
        'title': '集市供需',
        'description': '独立 marketplace 业务域，负责岗位交易、服务包、曝光资源。',
        'badges': ['曝光包', '找工人', '招工发布'],
        'authed': authed,
      },
      '/message/summary' => {
        'title': '消息中心',
        'description': 'IM 与通知域，隔离会话列表、系统通知、红点同步。',
        'badges': ['未读 12', '系统通知 3', '招聘顾问'],
        'authed': authed,
      },
      '/mine/summary' => {
        'title': '个人中心',
        'description': '账号、角色、简历、认证等用户资产聚合域。',
        'badges': ['已登录', '简历 82%', '实名待完善'],
        'authed': authed,
      },
      _ => throw StateError('No mock response registered for $path'),
    };
  }

  Future<Map<String, Object?>> post(
    String path, {
    required Map<String, Object?> headers,
    Object? data,
    Map<String, Object?>? queryParameters,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final authed = headers['Authorization']?.toString().isNotEmpty ?? false;

    return switch (path) {
      '/mine/role/switch' => {
        'role': (data as Map<String, Object?>?)?['role'] ?? '求职者',
        'authed': authed,
      },
      _ => throw StateError('No mock response registered for $path'),
    };
  }
}

/// Dio mock 适配器。
///
/// demo 没有真实后端，但仍让请求完整经过 Dio adapter 和 interceptor 链路。
class MockDioAdapter implements HttpClientAdapter {
  const MockDioAdapter(this._transport);

  final MockApiTransport _transport;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/demo/error') {
      return ResponseBody.fromString(
        jsonEncode({'code': 50001, 'message': '模拟接口错误：默认会弹 Toast'}),
        500,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'x-ask-id': ['mock-error-ask-id'],
        },
      );
    }

    final headers = options.headers.cast<String, Object?>();
    final queryParameters = options.queryParameters.cast<String, Object?>();
    final payload = switch (options.method.toUpperCase()) {
      'GET' => await _transport.get(
        options.path,
        headers: headers,
        queryParameters: queryParameters,
      ),
      'POST' => await _transport.post(
        options.path,
        headers: headers,
        queryParameters: queryParameters,
        data: options.data,
      ),
      _ =>
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          message: '不支持的 mock 请求方法：${options.method}',
        ),
    };

    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
