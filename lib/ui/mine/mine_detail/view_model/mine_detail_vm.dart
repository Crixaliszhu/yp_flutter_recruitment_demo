import '../../../../data/mine/repo/mine_repo.dart';
import '../../../core/view_model/base_vm.dart';
import '../ui_state/mine_detail_us.dart';

/// 个人中心二级页的 ViewModel。
class MineDetailVM extends BaseVM<MineDetailUS> {
  MineDetailVM() : _repo = MineRepo(), super(const MineDetailUS(role: '求职者'));

  final MineRepoContract _repo;

  Future<void> switchRole(String role) async {
    final result = await _repo.switchRole(role);
    final next = result.data;
    if (result.isOK() && next != null) {
      safeEmit(state.copyWith(role: next));
    }
  }
}
