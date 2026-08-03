import '../../../../data/home/repo/home_repo.dart';
import '../../../core/view_model/base_vm.dart';
import '../ui_state/home_tab_us.dart';

/// 首页 tab 的 ViewModel。
class HomeTabVM extends BaseVM<HomeTabUS> {
  HomeTabVM() : _repo = HomeRepo(), super(const HomeTabUS.initial());

  final HomeRepoContract _repo;

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
        errorMessage: result.fail?.message ?? '首页数据加载失败',
      ),
    );
  }
}
