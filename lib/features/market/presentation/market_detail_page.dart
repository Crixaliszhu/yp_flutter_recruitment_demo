import 'package:flutter/material.dart';

import '../../../shared/presentation/scene_card.dart';
import '../domain/market_use_case.dart';

/// 集市域二级页。
///
/// 可继续扩展为服务包详情、曝光资源购买页等完整业务链路。
class MarketDetailPage extends StatelessWidget {
  const MarketDetailPage({super.key, required this.useCase});

  final MarketUseCase useCase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('集市二级页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SceneCard(
            icon: Icons.inventory_2_outlined,
            title: '业务域：market',
            body: '这里可以承载服务包详情、招工发布权益、找工人曝光套餐等交易链路。',
          ),
          SizedBox(height: 12),
          SceneCard(
            icon: Icons.receipt_long,
            title: '数据边界',
            body: '页面只依赖 MarketUseCase；网络、缓存、埋点可以在 data 层横向增强。',
          ),
        ],
      ),
    );
  }
}
