import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../../../../shared/widget/async_domain_page.dart';
import '../../../../shared/widget/scene_card.dart';
import '../ui_state/home_tab_us.dart';
import '../view_model/home_tab_vm.dart';

/// 首页一级 tab。
///
/// 页面只依赖 HomeTabVM；跨域跳转通过全局路由常量，不直接 import 其他业务域页面。
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  late final HomeTabVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = HomeTabVM()..loadSummary();
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTabVM, HomeTabUS>(
      bloc: _vm,
      builder: (context, uiState) {
        return AsyncDomainPage(
          title: '首页',
          isLoading: uiState.isLoading,
          summary: uiState.summary,
          errorMessage: uiState.errorMessage,
          primaryActionLabel: '进入首页二级页',
          onPrimaryAction:
              () => context.push(
                Uri(
                  path: AppRoutes.homeDetail,
                  queryParameters: {'jobId': 'job_10086', 'source': 'home_tab'},
                ).toString(),
              ),
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
              body: '业务动作通过 VM 编排，数据来自 Repo，页面只消费展示状态。',
            ),
          ],
        );
      },
    );
  }
}
