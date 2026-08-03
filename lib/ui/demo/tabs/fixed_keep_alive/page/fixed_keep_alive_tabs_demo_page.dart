import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ui_state/fixed_follow_tab_us.dart';
import '../view_model/fixed_follow_tab_vm.dart';

/// 固定少量 tab 的保活示例页。
///
/// 适合“我关注的 / 关注我的”这类数量固定、进入过就希望保存状态的页面。
class FixedKeepAliveTabsDemoPage extends StatelessWidget {
  const FixedKeepAliveTabsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('固定 Tab 保活示例'),
          bottom: TabBar(tabs: [Tab(text: '我关注的'), Tab(text: '关注我的')]),
        ),
        body: TabBarView(
          children: [
            _FollowKeepAliveTab(tabName: '我关注的'),
            _FollowKeepAliveTab(tabName: '关注我的'),
          ],
        ),
      ),
    );
  }
}

class _FollowKeepAliveTab extends StatefulWidget {
  const _FollowKeepAliveTab({required this.tabName});

  final String tabName;

  @override
  State<_FollowKeepAliveTab> createState() => _FollowKeepAliveTabState();
}

class _FollowKeepAliveTabState extends State<_FollowKeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  late final FixedFollowTabVM _vm;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _vm = FixedFollowTabVM(tabName: widget.tabName)..loadOnce();
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FixedFollowTabVM, FixedFollowTabUS>(
      bloc: _vm,
      builder: (context, uiState) {
        return ListView.separated(
          key: PageStorageKey<String>('fixed_tab_${widget.tabName}'),
          padding: const EdgeInsets.all(16),
          itemCount: uiState.items.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _FixedTabHeader(uiState: uiState, vm: _vm);
            }
            final item = uiState.items[index - 1];
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFE6EAF0)),
              ),
              title: Text(item),
              subtitle: const Text('切换 tab 再回来，滚动位置和点击次数会保留。'),
            );
          },
        );
      },
    );
  }
}

class _FixedTabHeader extends StatelessWidget {
  const _FixedTabHeader({required this.uiState, required this.vm});

  final FixedFollowTabUS uiState;
  final FixedFollowTabVM vm;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              uiState.tabName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('加载次数：${uiState.loadCount}'),
            Text('本 tab 点击次数：${uiState.clickCount}'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: vm.increaseClickCount,
              icon: const Icon(Icons.add),
              label: const Text('增加本 tab 状态'),
            ),
          ],
        ),
      ),
    );
  }
}
