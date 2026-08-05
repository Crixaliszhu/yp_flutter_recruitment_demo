/// 全局路由常量。
///
/// 跨业务域跳转只依赖这些 path，不直接 import 其他业务域页面，便于后续拆包。
class AppRoutes {
  const AppRoutes._();

  static const launch = '/launch';
  static const home = '/home';
  static const homeDetail = '/home/detail';
  static const market = '/market';
  static const marketDetail = '/market/detail';
  static const overlayDemo = '/demo/overlay';
  static const fixedTabsDemo = '/demo/tabs/fixed';
  static const dynamicPagerDemo = '/demo/tabs/dynamic-pager';
  static const mmkvStorageDemo = '/demo/storage/mmkv';
  static const isolateDemo = '/demo/isolate';
  static const message = '/message';
  static const messageDetail = '/message/detail';
  static const mine = '/mine';
  static const mineDetail = '/mine/detail';
}
