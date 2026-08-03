import '../../common/network/api_client.dart';
import '../../common/network/api_result.dart';

/// 个人中心远程数据源。
class MineRds {
  const MineRds(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<Map<String, Object?>>> fetchSummaryJson() {
    return _apiClient.getJson(
      '/mine/summary',
      headers: {'X-Biz-Domain': 'mine'},
    );
  }

  Future<ApiResult<Map<String, Object?>>> switchRoleJson(String role) {
    return _apiClient.postJson(
      '/mine/role/switch',
      data: {'role': role},
      headers: {'X-Biz-Action': 'switch-role'},
    );
  }
}
