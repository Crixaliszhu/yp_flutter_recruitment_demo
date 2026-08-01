import 'package:flutter/material.dart';

import '../routing/app_router.dart';
import 'app_dependencies.dart';

/// 应用根组件。
///
/// 这里只组装跨端通用能力：主题、全局路由和依赖容器。不要在根组件里写
/// 具体业务逻辑，业务应继续下沉到各 feature 的 presentation/domain/data。
class RecruitmentDemoApp extends StatelessWidget {
  const RecruitmentDemoApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    // Router 持有业务依赖，页面通过 UseCase 获取能力，避免页面自己 new data 层对象。
    final router = createAppRouter(dependencies);

    return MaterialApp.router(
      title: 'Yupao Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1677FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
