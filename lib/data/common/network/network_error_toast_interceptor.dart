import 'package:dio/dio.dart';

import '../../../ui/core/toast/app_toast.dart';

/// 通用错误 Toast 拦截器。
///
/// 默认接口错误会 Toast；不重要的静默接口可通过 RequestOptions.extra['allowErrorToast']
/// 设置为 false，避免打扰用户。
class NetworkErrorToastInterceptor extends Interceptor {
  static const allowErrorToastKey = 'allowErrorToast';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_allowErrorToast(err.requestOptions)) {
      final message = _resolveMessage(err);
      if (message.isNotEmpty) {
        AppToast.showText(message);
      }
    }
    handler.next(err);
  }

  bool _allowErrorToast(RequestOptions options) {
    return options.extra[allowErrorToastKey] != false;
  }

  String _resolveMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['errorMsg'] ?? data['msg'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }
    return err.message ?? '网络请求失败';
  }
}
