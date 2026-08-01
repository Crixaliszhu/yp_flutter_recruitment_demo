import '../../../shared/domain/domain_summary.dart';
import 'home_repository.dart';

/// 首页域业务用例。
///
/// 页面通过 UseCase 触发业务动作；当首页有推荐、筛选、曝光等组合逻辑时，
/// 优先放在这里编排，而不是堆到 Widget 中。
class HomeUseCase {
  const HomeUseCase(this._repository);

  final HomeRepository _repository;

  Future<DomainSummary> loadSummary() {
    return _repository.fetchSummary();
  }
}
