import '../../../app/app_runtime.dart';
import '../../common/network/api_result.dart';
import '../../../shared/model/domain_summary.dart';
import '../ds/market_rds.dart';

/// 仓库接口契约
abstract interface class MarketRepoContract {
  Future<ApiResult<DomainSummary>> fetchSummary();
}

/// 集市数据仓库。
class MarketRepo implements MarketRepoContract {
  MarketRepo() : _rds = MarketRds(AppRuntime.instance.apiClient);

  final MarketRds _rds;

  @override
  Future<ApiResult<DomainSummary>> fetchSummary() async {
    final result = await _rds.fetchSummaryJson();
    return result.mapResult((data) {
      if (data == null) {
        return null;
      }
      return DomainSummary.fromJson(data);
    });
  }
}
