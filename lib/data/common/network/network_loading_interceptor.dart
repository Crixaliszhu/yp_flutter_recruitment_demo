import 'package:dio/dio.dart';

import 'network_loading_controller.dart';

/// 基于 Dio 拦截器的全局 loading 处理。
///
/// 单个接口可以通过 RequestOptions.extra['showLoading'] 控制是否参与全局 loading。
class NetworkLoadingInterceptor extends Interceptor {
  NetworkLoadingInterceptor(this._controller);

  static const showLoadingKey = 'showLoading';

  final NetworkLoadingController _controller;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldShowLoading(options)) {
      _controller.show();
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_shouldShowLoading(response.requestOptions)) {
      _controller.dismiss();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldShowLoading(err.requestOptions)) {
      _controller.dismiss();
    }
    handler.next(err);
  }

  bool _shouldShowLoading(RequestOptions options) {
    return options.extra[showLoadingKey] == true;
  }
}
