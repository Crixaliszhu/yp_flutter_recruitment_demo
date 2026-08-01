import 'package:go_router/go_router.dart';

import '../app/app_dependencies.dart';
import '../features/home/presentation/home_detail_page.dart';
import '../features/home/presentation/home_tab_page.dart';
import '../features/market/presentation/market_detail_page.dart';
import '../features/market/presentation/market_tab_page.dart';
import '../features/message/presentation/message_detail_page.dart';
import '../features/message/presentation/message_tab_page.dart';
import '../features/mine/presentation/mine_detail_page.dart';
import '../features/mine/presentation/mine_tab_page.dart';
import '../shell/main_tab_scaffold.dart';
import 'app_routes.dart';

/// 创建应用路由表。
///
/// 一级 tab 放在 StatefulShellRoute 中，以保留每个 tab 的独立导航栈。二级页放在
/// shell 外层，这样打开后是完整独立页面，不会继续显示底部四个 tab。
GoRouter createAppRouter(AppDependencies dependencies) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabScaffold(navigationShell: navigationShell);
        },
        // 四个一级业务域：home、market、message、mine。
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) {
                  return HomeTabPage(useCase: dependencies.homeUseCase);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.market,
                builder: (context, state) {
                  return MarketTabPage(useCase: dependencies.marketUseCase);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.message,
                builder: (context, state) {
                  return MessageTabPage(useCase: dependencies.messageUseCase);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mine,
                builder: (context, state) {
                  return MineTabPage(useCase: dependencies.mineUseCase);
                },
              ),
            ],
          ),
        ],
      ),
      // 以下 detail 路由刻意放在 shell 外，避免业务二级页被底部 tab 容器包住。
      GoRoute(
        path: AppRoutes.homeDetail,
        builder: (context, state) {
          return HomeDetailPage(useCase: dependencies.homeUseCase);
        },
      ),
      GoRoute(
        path: AppRoutes.marketDetail,
        builder: (context, state) {
          return MarketDetailPage(useCase: dependencies.marketUseCase);
        },
      ),
      GoRoute(
        path: AppRoutes.messageDetail,
        builder: (context, state) {
          return MessageDetailPage(useCase: dependencies.messageUseCase);
        },
      ),
      GoRoute(
        path: AppRoutes.mineDetail,
        builder: (context, state) {
          return MineDetailPage(useCase: dependencies.mineUseCase);
        },
      ),
    ],
  );
}
