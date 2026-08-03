import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../routing/app_router.dart';

/// 应用根组件。
///
/// 这里只组装跨端通用能力：主题和全局路由。不要在根组件里写具体业务逻辑，
/// 业务应继续下沉到 `ui` 和 `data` 对应业务域。
class RecruitmentDemoApp extends StatelessWidget {
  const RecruitmentDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Router 只负责路由匹配和参数解析，不创建页面内部依赖。
    final router = createAppRouter();

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
      builder: (context, child) {
        return BotToastInit()(context, child ?? const SizedBox.shrink());
      },
    );
  }
}
