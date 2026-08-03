import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../../../../shared/widget/async_domain_page.dart';
import '../../../../shared/widget/scene_card.dart';
import '../ui_state/market_tab_us.dart';
import '../view_model/market_tab_vm.dart';

/// 集市一级 tab。
class MarketTabPage extends StatefulWidget {
  const MarketTabPage({super.key});

  @override
  State<MarketTabPage> createState() => _MarketTabPageState();
}

class _MarketTabPageState extends State<MarketTabPage> {
  late final MarketTabVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = MarketTabVM()..loadSummary();
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketTabVM, MarketTabUS>(
      bloc: _vm,
      builder: (context, uiState) {
        return AsyncDomainPage(
          title: '集市',
          isLoading: uiState.isLoading,
          summary: uiState.summary,
          errorMessage: uiState.errorMessage,
          primaryActionLabel: '进入集市二级页',
          onPrimaryAction:
              () => context.push(
                Uri(
                  path: AppRoutes.marketDetail,
                  queryParameters: {
                    'skuId': 'boost_pack_30',
                    'source': 'market_tab',
                  },
                ).toString(),
              ),
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
              body: '可单独拆包成 ui/market 和 data/market，保持与其他域低耦合。',
            ),
          ],
        );
      },
    );
  }
}
