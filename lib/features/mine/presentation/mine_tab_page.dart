import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../shared/presentation/async_domain_page.dart';
import '../../../shared/presentation/scene_card.dart';
import '../domain/mine_use_case.dart';

/// 个人中心一级 tab。
///
/// 用户资产入口，页面通过 MineUseCase 获取账号与角色相关能力。
class MineTabPage extends StatelessWidget {
  const MineTabPage({super.key, required this.useCase});

  final MineUseCase useCase;

  @override
  Widget build(BuildContext context) {
    return AsyncDomainPage(
      title: '个人中心',
      future: useCase.loadSummary(),
      primaryActionLabel: '进入个人中心二级页',
      onPrimaryAction: () => context.push(AppRoutes.mineDetail),
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
  }
}
