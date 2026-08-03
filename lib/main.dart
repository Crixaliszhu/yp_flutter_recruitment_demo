import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_bootstrap.dart';

/// Flutter 业务入口。
///
/// Android/iOS 原生侧只负责启动页和容器，首帧之后的页面、路由、网络、
/// 存储与业务编排都从这里进入 Flutter 层。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.init();
  runApp(const RecruitmentDemoApp());
}
