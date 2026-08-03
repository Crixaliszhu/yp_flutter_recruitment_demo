import '../../common/network/api_client.dart';
import '../../common/network/api_result.dart';

/// 首页远程数据源。
///
/// RDS 只封装单次远程请求；模型转换、兜底和缓存策略放在 Repo。
class HomeRds {
  const HomeRds(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<Map<String, Object?>>> fetchSummaryJson() {
    return _apiClient.getJson(
      '/home/summary',
      headers: {'X-Biz-Domain': 'home'},
    );
  }
}
