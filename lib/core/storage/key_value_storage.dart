/// 统一维护存储 key，避免字符串散落在各业务页面中。
class StorageKeys {
  const StorageKeys._();

  static const accessToken = 'auth.accessToken';
  static const selectedRole = 'mine.selectedRole';
}

/// 简单 KV 存储抽象。
///
/// 当前 demo 使用内存实现，避免为演示项目引入平台插件。真实项目可替换为
/// shared_preferences、flutter_secure_storage 或数据库实现，外部调用方不变。
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
