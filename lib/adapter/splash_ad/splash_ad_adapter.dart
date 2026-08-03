/// 开屏广告适配器。
///
/// 启动广告由 Android/iOS 原生承接；这里定义 Flutter 侧感知广告状态的统一入口。
/// 后续可以用 MethodChannel/Pigeon 接入真实原生广告 SDK 回调。
class SplashAdAdapter {
  const SplashAdAdapter();

  Future<void> waitForNativeSplashAdResult({
    required int fallbackMillis,
  }) async {
    await Future<void>.delayed(Duration(milliseconds: fallbackMillis));
  }
}
