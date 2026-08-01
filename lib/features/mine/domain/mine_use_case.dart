import '../../../shared/domain/domain_summary.dart';
import 'mine_repository.dart';

/// 个人中心域业务用例。
///
/// 当前演示角色切换；真实项目可继续扩展登录态刷新、实名流程、简历完善度计算。
class MineUseCase {
  const MineUseCase(this._repository);

  final MineRepository _repository;

  Future<DomainSummary> loadSummary() {
    return _repository.fetchSummary();
  }

  Future<String> switchRole(String role) {
    return _repository.switchRole(role);
  }
}
