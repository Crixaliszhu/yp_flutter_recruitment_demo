import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../../../../shared/widget/async_domain_page.dart';
import '../../../../shared/widget/scene_card.dart';
import '../ui_state/mine_tab_us.dart';
import '../view_model/mine_tab_vm.dart';

/// 个人中心一级 tab。
class MineTabPage extends StatefulWidget {
  const MineTabPage({super.key});

  @override
  State<MineTabPage> createState() => _MineTabPageState();
}

class _MineTabPageState extends State<MineTabPage> {
  late final MineTabVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = MineTabVM()..loadSummary();
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MineTabVM, MineTabUS>(
      bloc: _vm,
      builder: (context, uiState) {
        return AsyncDomainPage(
          title: '个人中心',
          isLoading: uiState.isLoading,
          summary: uiState.summary,
          errorMessage: uiState.errorMessage,
          primaryActionLabel: '进入个人中心二级页',
          onPrimaryAction:
              () => context.push(
                Uri(
                  path: AppRoutes.mineDetail,
                  queryParameters: {'section': 'role', 'source': 'mine_tab'},
                ).toString(),
              ),
          children: const [
            SceneCard(
              icon: Icons.badge_outlined,
              title: '账号资产',
              body: '个人中心域负责登录态、角色、简历、认证等用户资产，不让各业务页散落读写缓存。',
            ),
            SizedBox(height: 12),
            SceneCard(
              icon: Icons.settings_outlined,
              title: '本地存储',
              body: '示例中 token 和角色存在 KeyValueStorage，真实项目可替换安全存储或数据库。',
            ),
          ],
        );
      },
    );
  }
}
