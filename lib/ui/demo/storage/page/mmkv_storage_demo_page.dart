import 'package:flutter/material.dart';

import '../../../../app/app_runtime.dart';
import '../../../../data/common/storage/key_value_storage.dart';
import '../../../core/toast/app_toast.dart';

/// MMKV 非敏感 KV 示例页。
///
/// 页面同时演示两类用法：
/// 1. 普通 set/get：适合不需要响应式更新的轻量配置。
/// 2. watchXxx：适合主题、开关、昵称等需要多个页面实时响应的非敏感数据。
class MmkvStorageDemoPage extends StatefulWidget {
  const MmkvStorageDemoPage({super.key});

  @override
  State<MmkvStorageDemoPage> createState() => _MmkvStorageDemoPageState();
}

class _MmkvStorageDemoPageState extends State<MmkvStorageDemoPage> {
  late final KeyValueStorage _storage;
  final TextEditingController _nicknameController = TextEditingController();

  String _plainReadText = '尚未读取';

  @override
  void initState() {
    super.initState();
    _storage = AppRuntime.instance.storage;
    _loadNicknameToInput();
  }

  Future<void> _loadNicknameToInput() async {
    final nickname = await _storage.getString(StorageKeys.demoNickname);
    if (!mounted) {
      return;
    }
    _nicknameController.text = nickname ?? '渔泡用户';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveNickname() async {
    final value = _nicknameController.text.trim();
    await _storage.setString(
      StorageKeys.demoNickname,
      value.isEmpty ? '渔泡用户' : value,
    );
    AppToast.showText('昵称已写入 MMKV，并通知 watchString');
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _storage.setBool(StorageKeys.demoDarkMode, value);
  }

  Future<void> _increaseOpenCount() async {
    final current = await _storage.getInt(StorageKeys.demoOpenCount) ?? 0;
    await _storage.setInt(StorageKeys.demoOpenCount, current + 1);
  }

  Future<void> _plainRead() async {
    final nickname = await _storage.getString(StorageKeys.demoNickname);
    final darkMode = await _storage.getBool(StorageKeys.demoDarkMode);
    final openCount = await _storage.getInt(StorageKeys.demoOpenCount);
    setState(() {
      _plainReadText =
          '昵称：${nickname ?? '未设置'}\n'
          '深色模式：${darkMode == true ? '开启' : '关闭'}\n'
          '打开次数：${openCount ?? 0}';
    });
  }

  Future<void> _clearDemoValues() async {
    await _storage.remove(StorageKeys.demoNickname);
    await _storage.remove(StorageKeys.demoDarkMode);
    await _storage.remove(StorageKeys.demoOpenCount);
    if (!mounted) {
      return;
    }
    _nicknameController.text = '渔泡用户';
    setState(() {
      _plainReadText = '已清理，响应式区域会收到 null 后回到默认展示。';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MMKV 响应式 KV 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoSection(
            title: '响应式监听',
            description: 'watchXxx 会先发出当前值，后续 set/remove 时继续通知页面刷新。',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<String?>(
                  stream: _storage.watchString(StorageKeys.demoNickname),
                  builder: (context, snapshot) {
                    return Text('watchString 昵称：${snapshot.data ?? '未设置'}');
                  },
                ),
                const SizedBox(height: 8),
                StreamBuilder<bool?>(
                  stream: _storage.watchBool(StorageKeys.demoDarkMode),
                  builder: (context, snapshot) {
                    final enabled = snapshot.data ?? false;
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('watchBool 深色模式开关'),
                      value: enabled,
                      onChanged: _toggleDarkMode,
                    );
                  },
                ),
                StreamBuilder<int?>(
                  stream: _storage.watchInt(StorageKeys.demoOpenCount),
                  builder: (context, snapshot) {
                    return Text('watchInt 计数：${snapshot.data ?? 0}');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DemoSection(
            title: '普通写入',
            description: 'setString/setBool/setInt 既会写入 MMKV，也会通知对应 key 的监听者。',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '昵称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saveNickname,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('保存昵称'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _increaseOpenCount,
                  icon: const Icon(Icons.add),
                  label: const Text('计数 +1'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DemoSection(
            title: '纯 get 读取',
            description: '不需要响应式的场景可以直接 getXxx，读取后自行决定是否 setState。',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_plainReadText),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _plainRead,
                  icon: const Icon(Icons.read_more_outlined),
                  label: const Text('普通读取一次'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _clearDemoValues,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('清理示例数据'),
                ),
              ],
            ),
          ),
        ],
      ),
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
