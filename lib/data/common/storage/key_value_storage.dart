import 'dart:async';

import 'package:mmkv/mmkv.dart';

/// 共享存储 key。
///
/// 统一维护 key，避免页面和 VM 中散落重复字符串。
class StorageKeys {
  const StorageKeys._();

  static const accessToken = 'auth.accessToken';
  static const selectedRole = 'mine.selectedRole';
  static const demoNickname = 'demo.mmkv.nickname';
  static const demoDarkMode = 'demo.mmkv.darkMode';
  static const demoOpenCount = 'demo.mmkv.openCount';
}

/// 简单 KV 存储门面。
///
/// 当前 demo 使用 MMKV 作为非敏感 KV 的落盘实现，并在 Flutter 层补充响应式通知。
/// 若测试环境或桌面环境无法加载 MMKV 插件，会降级到内存实现，避免影响单元测试。
class KeyValueStorage {
  KeyValueStorage._(this._backend);

  final _KvBackend _backend;
  final Map<String, StreamController<Object?>> _controllers = {};

  static Future<KeyValueStorage> create() async {
    try {
      await MMKV.initialize(logLevel: MMKVLogLevel.Warning);
      return KeyValueStorage._(_MmkvBackend(MMKV.defaultMMKV()));
    } on Object {
      // 测试环境可能没有注册平台插件；demo 降级内存实现，真实项目应在启动阶段暴露初始化错误。
      return KeyValueStorage._(_MemoryKvBackend());
    }
  }

  Future<void> setString(String key, String value) async {
    await _backend.setString(key, value);
    _notify(key, value);
  }

  Future<String?> getString(String key) async {
    return _backend.getString(key);
  }

  Stream<String?> watchString(String key) {
    return _watch<String>(key, () => getString(key));
  }

  Future<void> setBool(String key, bool value) async {
    await _backend.setBool(key, value);
    _notify(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _backend.getBool(key);
  }

  Stream<bool?> watchBool(String key) {
    return _watch<bool>(key, () => getBool(key));
  }

  Future<void> setInt(String key, int value) async {
    await _backend.setInt(key, value);
    _notify(key, value);
  }

  Future<int?> getInt(String key) async {
    return _backend.getInt(key);
  }

  Stream<int?> watchInt(String key) {
    return _watch<int>(key, () => getInt(key));
  }

  Future<void> setDouble(String key, double value) async {
    await _backend.setDouble(key, value);
    _notify(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _backend.getDouble(key);
  }

  Stream<double?> watchDouble(String key) {
    return _watch<double>(key, () => getDouble(key));
  }

  Future<void> remove(String key) async {
    await _backend.remove(key);
    _notify(key, null);
  }

  Stream<T?> _watch<T>(String key, Future<T?> Function() readCurrent) {
    return Stream<T?>.multi((controller) async {
      controller.add(await readCurrent());
      final subscription = _controllerFor(key).stream.listen((value) {
        controller.add(value as T?);
      });
      controller.onCancel = subscription.cancel;
    });
  }

  StreamController<Object?> _controllerFor(String key) {
    return _controllers.putIfAbsent(
      key,
      () => StreamController<Object?>.broadcast(),
    );
  }

  void _notify(String key, Object? value) {
    final controller = _controllers[key];
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(value);
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
    _backend.close();
  }
}

abstract class _KvBackend {
  Future<void> setString(String key, String value);

  Future<String?> getString(String key);

  Future<void> setBool(String key, bool value);

  Future<bool?> getBool(String key);

  Future<void> setInt(String key, int value);

  Future<int?> getInt(String key);

  Future<void> setDouble(String key, double value);

  Future<double?> getDouble(String key);

  Future<void> remove(String key);

  void close();
}

class _MmkvBackend implements _KvBackend {
  _MmkvBackend(this._mmkv);

  final MMKV _mmkv;

  @override
  Future<void> setString(String key, String value) async {
    _mmkv.encodeString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _mmkv.decodeString(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _mmkv.encodeBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    if (!_mmkv.containsKey(key)) {
      return null;
    }
    return _mmkv.decodeBool(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    _mmkv.encodeInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    if (!_mmkv.containsKey(key)) {
      return null;
    }
    return _mmkv.decodeInt(key);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _mmkv.encodeDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    if (!_mmkv.containsKey(key)) {
      return null;
    }
    return _mmkv.decodeDouble(key);
  }

  @override
  Future<void> remove(String key) async {
    _mmkv.removeValue(key);
  }

  @override
  void close() {
    _mmkv.close();
  }
}

class _MemoryKvBackend implements _KvBackend {
  final Map<String, Object?> _memory = <String, Object?>{};

  @override
  Future<void> setString(String key, String value) async {
    _memory[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _memory[key] as String?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _memory[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    return _memory[key] as bool?;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _memory[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    return _memory[key] as int?;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _memory[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async {
    return _memory[key] as double?;
  }

  @override
  Future<void> remove(String key) async {
    _memory.remove(key);
  }

  @override
  void close() {}
}
