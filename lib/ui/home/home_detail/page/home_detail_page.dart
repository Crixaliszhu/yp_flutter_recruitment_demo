import 'package:flutter/material.dart';

import '../../../../shared/widget/scene_card.dart';

class HomeDetailArgs {
  const HomeDetailArgs({required this.jobId, required this.source});

  factory HomeDetailArgs.fromQuery(Map<String, String> query) {
    return HomeDetailArgs(
      jobId: query['jobId'] ?? 'unknown_job',
      source: query['source'] ?? 'unknown',
    );
  }

  final String jobId;
  final String source;
}

/// 首页业务域二级页。
///
/// 该路由注册在 tab shell 外层，因此是完整独立页面，不显示底部 tab。
class HomeDetailPage extends StatelessWidget {
  const HomeDetailPage({super.key, required this.args});

  final HomeDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页二级页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('职位参数：${args.jobId}，来源：${args.source}'),
          const SizedBox(height: 12),
          const SceneCard(
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
