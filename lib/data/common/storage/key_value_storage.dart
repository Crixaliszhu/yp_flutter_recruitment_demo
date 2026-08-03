/// 共享存储 key。
///
/// 统一维护 key，避免页面和 VM 中散落重复字符串。
class StorageKeys {
  const StorageKeys._();

  static const accessToken = 'auth.accessToken';
  static const selectedRole = 'mine.selectedRole';
}

/// 简单 KV 存储抽象。
///
/// demo 使用内存实现，避免引入平台插件；生产项目可替换为安全存储、MMKV 或数据库。
class KeyValueStorage {
  KeyValueStorage._();

  final Map<String, String> _memory = <String, String>{};

  static Future<KeyValueStorage> create() async {
    return KeyValueStorage._();
  }

  Future<void> setString(String key, String value) async {
    _memory[key] = value;
  }

  Future<String?> getString(String key) async {
    return _memory[key];
  }
}
