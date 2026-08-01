import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../shared/presentation/async_domain_page.dart';
import '../../../shared/presentation/scene_card.dart';
import '../domain/message_use_case.dart';

/// 消息一级 tab。
///
/// 负责消息域入口展示，后续可接入 IM 会话列表、系统通知和红点同步。
class MessageTabPage extends StatelessWidget {
  const MessageTabPage({super.key, required this.useCase});

  final MessageUseCase useCase;

  @override
  Widget build(BuildContext context) {
    return AsyncDomainPage(
      title: '消息',
      future: useCase.loadSummary(),
      primaryActionLabel: '进入消息二级页',
      onPrimaryAction: () => context.push(AppRoutes.messageDetail),
      children: const [
        SceneCard(
          icon: Icons.mark_chat_unread_outlined,
          title: '会话列表',
          body: '消息域负责 IM 会话、系统通知和红点同步，可以替换成真实长连接实现。',
        ),
        SizedBox(height: 12),
        SceneCard(
          icon: Icons.notifications_active_outlined,
          title: '通知聚合',
          body: '跨端 Flutter 页面复用一套展示逻辑，平台只提供推送唤起和启动参数。',
        ),
      ],
    );
  }
}
