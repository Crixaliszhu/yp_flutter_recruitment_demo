import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../shared/presentation/async_domain_page.dart';
import '../../../shared/presentation/scene_card.dart';
import '../domain/home_use_case.dart';

/// 首页一级 tab。
///
/// 作为 main/yupao 域入口，只依赖 HomeUseCase，不直接触碰其他业务域实现。
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key, required this.useCase});

  final HomeUseCase useCase;

  @override
  Widget build(BuildContext context) {
    return AsyncDomainPage(
      title: '首页',
      future: useCase.loadSummary(),
      primaryActionLabel: '进入首页二级页',
      onPrimaryAction: () => context.push(AppRoutes.homeDetail),
      children: const [
        SceneCard(
          icon: Icons.work_outline,
          title: '推荐职位流',
          body: '首页域只关心岗位推荐、筛选状态、曝光点击，不直接依赖消息或个人中心实现。',
        ),
        SizedBox(height: 12),
        SceneCard(
          icon: Icons.checklist,
          title: '待办跟进',
          body: '业务动作通过用例层编排，数据来自 repository，页面只消费 ViewState。',
        ),
      ],
    );
  }
}
