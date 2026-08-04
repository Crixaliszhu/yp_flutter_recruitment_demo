import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../../../../shared/widget/scene_card.dart';
import '../ui_state/market_detail_us.dart';
import '../view_model/market_detail_vm.dart';

class MarketDetailArgs {
  const MarketDetailArgs({required this.skuId, required this.source});

  factory MarketDetailArgs.fromQuery(Map<String, String> query) {
    return MarketDetailArgs(
      skuId: query['skuId'] ?? 'unknown_sku',
      source: query['source'] ?? 'unknown',
    );
  }

  final String skuId;
  final String source;
}

/// 集市业务域二级页。
class MarketDetailPage extends StatefulWidget {
  const MarketDetailPage({super.key, required this.args});

  final MarketDetailArgs args;

  @override
  State<MarketDetailPage> createState() => _MarketDetailPageState();
}

class _MarketDetailPageState extends State<MarketDetailPage> {
  late final MarketDetailVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = MarketDetailVM(skuId: widget.args.skuId);
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('集市二级页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('商品参数：${widget.args.skuId}，来源：${widget.args.source}'),
          const SizedBox(height: 12),
          _ActionPanel(vm: _vm),
          const SizedBox(height: 12),
          _ComposedStatePanel(vm: _vm),
          const SizedBox(height: 12),
          _SelectorStatePanel(vm: _vm),
          const SizedBox(height: 12),
          _BuildWhenStatePanel(vm: _vm),
          const SizedBox(height: 12),
          _WholeStatePanel(vm: _vm),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.overlayDemo),
            icon: const Icon(Icons.layers_outlined),
            label: const Text('查看 Overlay / Toast / Loading 示例'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.fixedTabsDemo),
            icon: const Icon(Icons.tab_outlined),
            label: const Text('固定少量 Tab 保活示例'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.dynamicPagerDemo),
            icon: const Icon(Icons.view_carousel_outlined),
            label: const Text('动态频道 PageView 缓存示例'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.mmkvStorageDemo),
            icon: const Icon(Icons.storage_outlined),
            label: const Text('MMKV 响应式 KV 示例'),
          ),
          const SizedBox(height: 12),
          const SceneCard(
            icon: Icons.receipt_long,
            title: '页面结论',
            body:
                '页面可以有一个主 UIState，主状态内组合多个子状态；局部 UI 用 BlocSelector 或 buildWhen 控制刷新范围。',
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.vm});

  final MarketDetailVM vm;

  @override
  Widget build(BuildContext context) {
    return _DemoSection(
      title: '状态变化入口',
      description: '点击不同按钮，只改变 UIState 中的某一个子状态。',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: vm.changePrice,
            icon: const Icon(Icons.sell_outlined),
            label: const Text('改变价格'),
          ),
          OutlinedButton.icon(
            onPressed: vm.reduceStock,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('减少库存'),
          ),
          OutlinedButton.icon(
            onPressed: vm.toggleFilter,
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('切换筛选'),
          ),
        ],
      ),
    );
  }
}

class _WholeStatePanel extends StatelessWidget {
  const _WholeStatePanel({required this.vm});

  final MarketDetailVM vm;
  static var _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketDetailVM, MarketDetailUS>(
      bloc: vm,
      builder: (context, uiState) {
        _buildCount += 1;
        return _DemoSection(
          title: '1. BlocBuilder 包裹区域',
          description: '这块区域监听完整 MarketDetailUS，任意子状态变化都会重新 build。',
          child: Text(
            'build 次数：$_buildCount\n'
            '价格：${uiState.price.priceText}\n'
            '库存：${uiState.stock.count}\n'
            '筛选：${uiState.filter.onlyAvailable ? '仅可售' : '全部'}',
          ),
        );
      },
    );
  }
}

class _ComposedStatePanel extends StatelessWidget {
  const _ComposedStatePanel({required this.vm});

  final MarketDetailVM vm;
  static var _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketDetailVM, MarketDetailUS>(
      bloc: vm,
      builder: (context, uiState) {
        _buildCount += 1;
        return _DemoSection(
          title: '2. 一个主 UIState 组合多个子状态',
          description:
              '复杂页面不必拆成很多散乱状态，可以让主 UIState 聚合 header、price、stock、filter。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('build次数：$_buildCount'),
              Text('header.title：${uiState.header.title}'),
              Text('price.priceText：${uiState.price.priceText}'),
              Text('stock.count：${uiState.stock.count}'),
              Text('filter.onlyAvailable：${uiState.filter.onlyAvailable}'),
            ],
          ),
        );
      },
    );
  }
}

class _SelectorStatePanel extends StatelessWidget {
  const _SelectorStatePanel({required this.vm});

  final MarketDetailVM vm;
  static var _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketDetailVM, MarketDetailUS, MarketPriceUS>(
      bloc: vm,
      selector: (uiState) => uiState.price,
      builder: (context, priceState) {
        _buildCount += 1;
        return _DemoSection(
          title: '3. BlocSelector 局部刷新',
          description: '这块只选择 price 子状态；减少库存或切换筛选时，它不会重新 build。',
          child: Text(
            'build 次数：$_buildCount\n'
            '当前价格：${priceState.priceText}\n'
            '价格说明：${priceState.discountText}',
          ),
        );
      },
    );
  }
}

class _BuildWhenStatePanel extends StatelessWidget {
  const _BuildWhenStatePanel({required this.vm});

  final MarketDetailVM vm;
  static var _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketDetailVM, MarketDetailUS>(
      bloc: vm,
      buildWhen: (previous, current) => previous.stock != current.stock,
      builder: (context, uiState) {
        _buildCount += 1;
        return _DemoSection(
          title: '4. buildWhen 控制刷新条件',
          description: '这块只在 stock 子状态变化时 build；改变价格不会触发这里刷新。',
          child: Text(
            'build 次数：$_buildCount\n'
            '库存数量：${uiState.stock.count}\n'
            '库存状态：${uiState.stock.warningText}',
          ),
        );
      },
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
