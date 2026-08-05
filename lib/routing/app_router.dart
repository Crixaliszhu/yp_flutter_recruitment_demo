import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';

import '../ui/core/shell/main_tab_scaffold.dart';
import '../ui/demo/isolate/page/isolate_demo_page.dart';
import '../ui/demo/overlay/page/overlay_demo_page.dart';
import '../ui/demo/storage/page/mmkv_storage_demo_page.dart';
import '../ui/demo/tabs/dynamic_pager/page/dynamic_pager_demo_page.dart';
import '../ui/demo/tabs/fixed_keep_alive/page/fixed_keep_alive_tabs_demo_page.dart';
import '../ui/home/home_detail/page/home_detail_page.dart';
import '../ui/home/home_tab/page/home_tab_page.dart';
import '../ui/launch/launch_page/page/launch_page.dart';
import '../ui/market/market_detail/page/market_detail_page.dart';
import '../ui/market/market_tab/page/market_tab_page.dart';
import '../ui/message/message_detail/page/message_detail_page.dart';
import '../ui/message/message_tab/page/message_tab_page.dart';
import '../ui/mine/mine_detail/page/mine_detail_page.dart';
import '../ui/mine/mine_tab/page/mine_tab_page.dart';
import 'app_routes.dart';

/// 创建应用路由表。
///
/// `/launch` 是原生启动/广告之后的 Flutter 启动业务页。一级 tab 放在
/// StatefulShellRoute 内，二级页放在外层，避免保留底部 tab。
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.launch,
    observers: [BotToastNavigatorObserver()],
    routes: [
      GoRoute(
        path: AppRoutes.launch,
        builder: (context, state) {
          return const LaunchPage();
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) {
                  return const HomeTabPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.market,
                builder: (context, state) {
                  return const MarketTabPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.message,
                builder: (context, state) {
                  return const MessageTabPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mine,
                builder: (context, state) {
                  return const MineTabPage();
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.homeDetail,
        builder: (context, state) {
          return HomeDetailPage(
            args: HomeDetailArgs.fromQuery(state.uri.queryParameters),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.marketDetail,
        builder: (context, state) {
          return MarketDetailPage(
            args: MarketDetailArgs.fromQuery(state.uri.queryParameters),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.overlayDemo,
        builder: (context, state) {
          return const OverlayDemoPage();
        },
      ),
      GoRoute(
        path: AppRoutes.fixedTabsDemo,
        builder: (context, state) {
          return const FixedKeepAliveTabsDemoPage();
        },
      ),
      GoRoute(
        path: AppRoutes.dynamicPagerDemo,
        builder: (context, state) {
          return const DynamicPagerDemoPage();
        },
      ),
      GoRoute(
        path: AppRoutes.mmkvStorageDemo,
        builder: (context, state) {
          return const MmkvStorageDemoPage();
        },
      ),
      GoRoute(
        path: AppRoutes.isolateDemo,
        builder: (context, state) {
          return const IsolateDemoPage();
        },
      ),
      GoRoute(
        path: AppRoutes.messageDetail,
        builder: (context, state) {
          return MessageDetailPage(
            args: MessageDetailArgs.fromQuery(state.uri.queryParameters),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.mineDetail,
        builder: (context, state) {
          return MineDetailPage(
            args: MineDetailArgs.fromQuery(state.uri.queryParameters),
          );
        },
      ),
    ],
  );
}
