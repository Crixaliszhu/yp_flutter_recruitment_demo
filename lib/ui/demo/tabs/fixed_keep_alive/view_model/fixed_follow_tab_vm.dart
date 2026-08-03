import '../../../../core/view_model/base_vm.dart';
import '../ui_state/fixed_follow_tab_us.dart';

/// 固定数量子 tab 的 VM。
///
/// loadOnce 用于演示“第一次进入加载，切走再切回不重复加载”的场景。
class FixedFollowTabVM extends BaseVM<FixedFollowTabUS> {
  FixedFollowTabVM({required String tabName})
    : super(FixedFollowTabUS.initial(tabName));

  bool _loaded = false;

  Future<void> loadOnce() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    await Future<void>.delayed(const Duration(milliseconds: 260));
    safeEmit(
      state.copyWith(
        loadCount: state.loadCount + 1,
        items: List<String>.generate(
          30,
          (index) => '${state.tabName} 用户 ${index + 1}',
        ),
      ),
    );
  }

  void increaseClickCount() {
    safeEmit(state.copyWith(clickCount: state.clickCount + 1));
  }
}
