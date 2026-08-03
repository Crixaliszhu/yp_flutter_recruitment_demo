import 'package:flutter/foundation.dart';

/// 网络请求 loading 控制器。
///
/// 拦截器只维护请求计数，真正的 loading 展示由外部注入的回调完成。
class NetworkLoadingController {
  NetworkLoadingController({required this.onShow, required this.onDismiss});

  final VoidCallback onShow;
  final VoidCallback onDismiss;
  final ValueNotifier<int> _requestCount = ValueNotifier<int>(0);

  ValueListenable<int> get requestCount => _requestCount;

  bool get isLoading => _requestCount.value > 0;

  void show() {
    if (_requestCount.value == 0) {
      onShow();
    }
    _requestCount.value += 1;
  }

  void dismiss() {
    if (_requestCount.value == 0) {
      return;
    }
    _requestCount.value -= 1;
    if (_requestCount.value == 0) {
      onDismiss();
    }
  }
}
