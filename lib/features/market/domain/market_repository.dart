import '../../../shared/domain/domain_summary.dart';

/// 集市域的数据能力接口。
///
/// 交易、商品、权益等实现细节留在 data 层，避免外部业务直接感知接口形态。
abstract interface class MarketRepository {
  Future<DomainSummary> fetchSummary();
}
