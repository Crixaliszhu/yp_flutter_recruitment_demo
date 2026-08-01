import 'package:flutter/material.dart';

import '../../../shared/presentation/scene_card.dart';
import '../domain/home_use_case.dart';

/// 首页域二级页。
///
/// 该页面注册在 tab shell 外层，打开时不显示底部 tab，模拟完整业务详情页。
class HomeDetailPage extends StatelessWidget {
  const HomeDetailPage({super.key, required this.useCase});

  final HomeUseCase useCase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页二级页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SceneCard(
            icon: Icons.route,
            title: '业务域：main/yupao',
            body: '这里演示首页域的二级流程，例如职位详情聚合、报名入口、首页策略实验。',
          ),
          SizedBox(height: 12),
          SceneCard(
            icon: Icons.hub_outlined,
            title: '跨域交互',
            body: '若需要打开聊天，不直接 import message 页面，而是通过统一路由或领域服务触发。',
          ),
        ],
      ),
    );
  }
}
