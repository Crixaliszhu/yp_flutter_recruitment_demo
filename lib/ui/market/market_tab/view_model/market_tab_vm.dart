import '../../../../data/market/repo/market_repo.dart';
import '../../../core/view_model/base_vm.dart';
import '../ui_state/market_tab_us.dart';

/// 集市 tab 的 ViewModel。
class MarketTabVM extends BaseVM<MarketTabUS> {
  MarketTabVM() : _repo = MarketRepo(), super(const MarketTabUS.initial());

  final MarketRepoContract _repo;

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
        errorMessage: result.fail?.message ?? '集市数据加载失败',
      ),
    );
  }
}
