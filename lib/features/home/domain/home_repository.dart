import '../../../shared/domain/domain_summary.dart';

/// 首页域的数据能力接口。
///
/// presentation/domain 只依赖接口，真实数据来源由 data 层实现，便于测试和模块替换。
abstract interface class HomeRepository {
  Future<DomainSummary> fetchSummary();
}
