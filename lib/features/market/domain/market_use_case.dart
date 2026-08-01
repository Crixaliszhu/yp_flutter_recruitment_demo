import '../../../shared/domain/domain_summary.dart';
import 'market_repository.dart';

/// 集市域业务用例。
///
/// 适合承载曝光包、服务包、发布权益等交易链路的业务编排。
class MarketUseCase {
  const MarketUseCase(this._repository);

  final MarketRepository _repository;

  Future<DomainSummary> loadSummary() {
    return _repository.fetchSummary();
  }
}
