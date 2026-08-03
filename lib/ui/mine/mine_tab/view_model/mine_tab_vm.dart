import '../../../../data/mine/repo/mine_repo.dart';
import '../../../core/view_model/base_vm.dart';
import '../ui_state/mine_tab_us.dart';

/// 个人中心 tab 的 ViewModel。
class MineTabVM extends BaseVM<MineTabUS> {
  MineTabVM() : _repo = MineRepo(), super(const MineTabUS.initial());

  final MineRepoContract _repo;

  Future<void> loadSummary() async {
    safeEmit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repo.fetchSummary();
    final summary = result.data;
    if (result.isOK() && summary != null) {
      safeEmit(
        state.copyWith(isLoading: false, summary: summary, clearError: true),
      );
      return;
    }
    safeEmit(
      state.copyWith(
        isLoading: false,
        errorMessage: result.fail?.message ?? '个人中心数据加载失败',
      ),
    );
  }
}
