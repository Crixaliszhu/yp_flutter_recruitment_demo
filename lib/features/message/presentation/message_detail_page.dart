import 'package:flutter/material.dart';

import '../../../shared/presentation/scene_card.dart';
import '../domain/message_use_case.dart';

/// 消息域二级页。
///
/// 可作为聊天详情、系统通知落地页或原生推送 payload 跳转目标。
class MessageDetailPage extends StatelessWidget {
  const MessageDetailPage({super.key, required this.useCase});

  final MessageUseCase useCase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息二级页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SceneCard(
            icon: Icons.forum_outlined,
            title: '业务域：message',
            body: '这里演示聊天详情、招呼语模板、系统通知落地页等消息域二级页面。',
          ),
          SizedBox(height: 12),
          SceneCard(
            icon: Icons.sync_alt,
            title: '跨端通道',
            body: '真实项目中可用 MethodChannel/Pigeon 接收原生推送 payload，再走 Flutter 路由。',
          ),
        ],
      ),
    );
  }
}
