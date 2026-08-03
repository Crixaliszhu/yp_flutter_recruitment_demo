import '../../../app/app_runtime.dart';
import '../../common/network/api_result.dart';
import '../../../shared/model/domain_summary.dart';
import '../ds/home_rds.dart';

abstract interface class HomeRepoContract {
  Future<ApiResult<DomainSummary>> fetchSummary();
}

/// 首页数据仓库。
///
/// Repo 是 UI 层访问数据的稳定入口，负责把原始数据转换成业务可用模型。
class HomeRepo implements HomeRepoContract {
  HomeRepo() : _rds = HomeRds(AppRuntime.instance.apiClient);

  final HomeRds _rds;

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
}
