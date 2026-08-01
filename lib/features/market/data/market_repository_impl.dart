import '../../../core/network/api_client.dart';
import '../../../shared/domain/domain_summary.dart';
import '../domain/market_repository.dart';

/// 集市域 Repository 实现。
///
/// 当前读取 mock 接口；真实项目可在这里组合缓存、库存接口和支付前置校验。
class MarketRepositoryImpl implements MarketRepository {
  const MarketRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DomainSummary> fetchSummary() async {
    final result = await _apiClient.getJson('/market/summary');
    return DomainSummary.fromJson(result.requireData());
  }
}
