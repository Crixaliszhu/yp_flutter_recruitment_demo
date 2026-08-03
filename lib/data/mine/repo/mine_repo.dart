import '../../../app/app_runtime.dart';
import '../../common/network/api_result.dart';
import '../../../shared/model/domain_summary.dart';
import '../../common/storage/key_value_storage.dart';
import '../ds/mine_rds.dart';

abstract interface class MineRepoContract {
  Future<ApiResult<DomainSummary>> fetchSummary();

  Future<ApiResult<String>> switchRole(String role);
}

/// 个人中心数据仓库。
///
/// 这里组合远程数据和本地角色存储，演示同一业务域内 Repo 可以协调多个数据源。
class MineRepo implements MineRepoContract {
  MineRepo()
    : _rds = MineRds(AppRuntime.instance.apiClient),
      _storage = AppRuntime.instance.storage;

  final MineRds _rds;
  final KeyValueStorage _storage;

  @override
  Future<ApiResult<DomainSummary>> fetchSummary() async {
    final result = await _rds.fetchSummaryJson();
    return result.mapResult((json) {
      if (json == null) {
        return null;
      }
      return DomainSummary.fromJson(json);
    });
  }

  @override
  Future<ApiResult<String>> switchRole(String role) async {
    final result = await _rds.switchRoleJson(role);
    final mapped = result.mapResult<String>((json) {
      return json?['role'] as String? ?? role;
    });
    final nextRole = mapped.data;
    if (mapped.isOK() && nextRole != null) {
      await _storage.setString(StorageKeys.selectedRole, nextRole);
    }
    return mapped;
  }
}
