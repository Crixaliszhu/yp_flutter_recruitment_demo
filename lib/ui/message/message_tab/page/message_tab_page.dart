import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../../../../shared/widget/async_domain_page.dart';
import '../../../../shared/widget/scene_card.dart';
import '../ui_state/message_tab_us.dart';
import '../view_model/message_tab_vm.dart';

/// 消息一级 tab。
class MessageTabPage extends StatefulWidget {
  const MessageTabPage({super.key});

  @override
  State<MessageTabPage> createState() => _MessageTabPageState();
}

class _MessageTabPageState extends State<MessageTabPage> {
  late final MessageTabVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = MessageTabVM()..loadSummary();
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageTabVM, MessageTabUS>(
      bloc: _vm,
      builder: (context, uiState) {
        return AsyncDomainPage(
          title: '消息',
          isLoading: uiState.isLoading,
          summary: uiState.summary,
          errorMessage: uiState.errorMessage,
          primaryActionLabel: '进入消息二级页',
          onPrimaryAction:
              () => context.push(
                Uri(
                  path: AppRoutes.messageDetail,
                  queryParameters: {
                    'conversationId': 'conv_9527',
                    'source': 'message_tab',
                  },
                ).toString(),
              ),
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
      },
    );
  }
}
