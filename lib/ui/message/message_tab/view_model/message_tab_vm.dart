import '../../../../data/message/repo/message_repo.dart';
import '../../../core/view_model/base_vm.dart';
import '../ui_state/message_tab_us.dart';

/// 消息 tab 的 ViewModel。
class MessageTabVM extends BaseVM<MessageTabUS> {
  MessageTabVM() : _repo = MessageRepo(), super(const MessageTabUS.initial());

  final MessageRepoContract _repo;

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
        errorMessage: result.fail?.message ?? '消息数据加载失败',
      ),
    );
  }
}
