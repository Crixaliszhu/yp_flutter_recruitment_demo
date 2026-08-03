import 'package:flutter/material.dart';

import '../../../../shared/widget/scene_card.dart';

class MessageDetailArgs {
  const MessageDetailArgs({required this.conversationId, required this.source});

  factory MessageDetailArgs.fromQuery(Map<String, String> query) {
    return MessageDetailArgs(
      conversationId: query['conversationId'] ?? 'unknown_conversation',
      source: query['source'] ?? 'unknown',
    );
  }

  final String conversationId;
  final String source;
}

/// 消息业务域二级页。
class MessageDetailPage extends StatelessWidget {
  const MessageDetailPage({super.key, required this.args});

  final MessageDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息二级页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('会话参数：${args.conversationId}，来源：${args.source}'),
          const SizedBox(height: 12),
          const SceneCard(
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
