import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/channel_tab.dart';
import '../ui_state/channel_tab_us.dart';
import '../view_model/channel_tab_vm.dart';

/// 动态频道 PageView 缓存示例页。
///
/// 适合频道数量不固定、只希望预加载当前页左右若干页的场景。
class DynamicPagerDemoPage extends StatefulWidget {
  const DynamicPagerDemoPage({super.key});

  @override
  State<DynamicPagerDemoPage> createState() => _DynamicPagerDemoPageState();
}

class _DynamicPagerDemoPageState extends State<DynamicPagerDemoPage> {
  static const int _cacheExtent = 1;

  final PageController _pageController = PageController();
  final Map<String, ChannelTabVM> _vmCache = {};
  final List<ChannelTab> _tabs = const [
    ChannelTab(id: 'recommend', title: '推荐'),
    ChannelTab(id: 'nearby', title: '附近'),
    ChannelTab(id: 'part_time', title: '兼职'),
    ChannelTab(id: 'full_time', title: '全职'),
    ChannelTab(id: 'service', title: '服务'),
    ChannelTab(id: 'tool', title: '工具'),
    ChannelTab(id: 'local', title: '本地'),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _preloadAround();
  }

  ChannelTabVM _getVM(ChannelTab tab) {
    return _vmCache.putIfAbsent(tab.id, () {
      final vm = ChannelTabVM(tab: tab);
      vm.loadOnce();
      return vm;
    });
  }

  void _jumpTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _preloadAround();
    _trimCache();
  }

  void _preloadAround() {
    for (
      var i = _currentIndex - _cacheExtent;
      i <= _currentIndex + _cacheExtent;
      i++
    ) {
      if (i >= 0 && i < _tabs.length) {
        _getVM(_tabs[i]);
      }
    }
  }

  void _trimCache() {
    final keepIds = <String>{};
    for (
      var i = _currentIndex - _cacheExtent;
      i <= _currentIndex + _cacheExtent;
      i++
    ) {
      if (i >= 0 && i < _tabs.length) {
        keepIds.add(_tabs[i].id);
      }
    }

    final removeIds =
        _vmCache.keys.where((id) => !keepIds.contains(id)).toList();
    for (final id in removeIds) {
      _vmCache.remove(id)?.close();
    }
  }

  @override
  void dispose() {
    for (final vm in _vmCache.values) {
      vm.close();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态 PageView 缓存示例')),
      body: Column(
        children: [
          _ChannelTabBar(
            tabs: _tabs,
            currentIndex: _currentIndex,
            cachedIds: _vmCache.keys.toSet(),
            onTap: _jumpTo,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              '当前缓存：${_vmCache.keys.join(', ')}。示例只保留当前频道和左右 $_cacheExtent 个频道。',
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _tabs.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final vm = _getVM(tab);
                return BlocProvider.value(
                  key: ValueKey(tab.id),
                  value: vm,
                  child: _ChannelPage(tab: tab),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelTabBar extends StatelessWidget {
  const _ChannelTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.cachedIds,
    required this.onTap,
  });

  final List<ChannelTab> tabs;
  final int currentIndex;
  final Set<String> cachedIds;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            ChoiceChip(
              label: Text(
                '${tabs[i].title}${cachedIds.contains(tabs[i].id) ? ' *' : ''}',
              ),
              selected: i == currentIndex,
              onSelected: (_) => onTap(i),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ChannelPage extends StatelessWidget {
  const _ChannelPage({required this.tab});

  final ChannelTab tab;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelTabVM, ChannelTabUS>(
      builder: (context, uiState) {
        return ListView.separated(
          key: PageStorageKey<String>('dynamic_channel_${tab.id}'),
          padding: const EdgeInsets.all(16),
          itemCount: uiState.items.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ChannelHeader(uiState: uiState);
            }
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFE6EAF0)),
              ),
              title: Text(uiState.items[index - 1]),
              subtitle: Text('频道 id：${uiState.channelId}'),
            );
          },
        );
      },
    );
  }
}

class _ChannelHeader extends StatelessWidget {
  const _ChannelHeader({required this.uiState});

  final ChannelTabUS uiState;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChannelTabVM>();
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
            Text(uiState.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('加载次数：${uiState.loadCount}'),
            Text('频道点击次数：${uiState.touchCount}'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: vm.increaseTouchCount,
              icon: const Icon(Icons.add),
              label: const Text('增加当前频道状态'),
            ),
          ],
        ),
      ),
    );
  }
}
