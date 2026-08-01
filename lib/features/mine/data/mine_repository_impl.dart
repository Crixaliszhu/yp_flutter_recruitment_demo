import '../../../core/network/api_client.dart';
import '../../../core/storage/key_value_storage.dart';
import '../../../shared/domain/domain_summary.dart';
import '../domain/mine_repository.dart';

/// 个人中心域 Repository 实现。
///
/// 这个实现同时使用网络和存储，展示 data 层可以组合多个基础设施能力。
class MineRepositoryImpl implements MineRepository {
  const MineRepositoryImpl(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final KeyValueStorage _storage;

  @override
  Future<DomainSummary> fetchSummary() async {
    final result = await _apiClient.getJson('/mine/summary');
    return DomainSummary.fromJson(result.requireData());
  }

  @override
  Future<String> switchRole(String role) async {
    // 角色属于个人中心域资产，统一由 Repository 写入，页面不直接接触存储 key。
    await _storage.setString(StorageKeys.selectedRole, role);
    return role;
  }
}
