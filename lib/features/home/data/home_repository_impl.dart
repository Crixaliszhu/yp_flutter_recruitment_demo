import '../../../core/network/api_client.dart';
import '../../../shared/domain/domain_summary.dart';
import '../domain/home_repository.dart';

/// 首页域 Repository 实现。
///
/// data 层负责把网络 DTO 转成 domain/presentation 可消费的模型。
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DomainSummary> fetchSummary() async {
    final result = await _apiClient.getJson('/home/summary');
    return DomainSummary.fromJson(result.requireData());
  }
}
