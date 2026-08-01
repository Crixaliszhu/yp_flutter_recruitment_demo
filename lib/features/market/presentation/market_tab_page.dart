import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../shared/presentation/async_domain_page.dart';
import '../../../shared/presentation/scene_card.dart';
import '../domain/market_use_case.dart';

/// 集市一级 tab。
///
/// 聚合交易、权益和供需匹配入口，页面只负责展示和触发路由。
class MarketTabPage extends StatelessWidget {
  const MarketTabPage({super.key, required this.useCase});

  final MarketUseCase useCase;

  @override
  Widget build(BuildContext context) {
    return AsyncDomainPage(
      title: '集市',
      future: useCase.loadSummary(),
      primaryActionLabel: '进入集市二级页',
      onPrimaryAction: () => context.push(AppRoutes.marketDetail),
      children: const [
        SceneCard(
          icon: Icons.campaign_outlined,
          title: '曝光资源',
          body: '集市域封装商品、权益、库存和支付前置校验，避免首页直接处理交易模型。',
        ),
        SizedBox(height: 12),
        SceneCard(
          icon: Icons.handshake_outlined,
          title: '供需匹配',
          body: '可单独拆包成 feature_market，保持与 recruitment、account 等域低耦合。',
        ),
      ],
    );
  }
}
