import '../../common/network/api_client.dart';
import '../../common/network/api_result.dart';

/// 集市远程数据源。
class MarketRds {
  const MarketRds(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<Map<String, Object?>>> fetchSummaryJson() {
    return _apiClient.getJson(
      '/market/summary',
      headers: {'X-Biz-Domain': 'market'},
    );
  }
}
