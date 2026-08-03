import '../../../../core/view_model/base_vm.dart';
import '../model/channel_tab.dart';
import '../ui_state/channel_tab_us.dart';

/// 动态频道子页 VM。
///
/// 父页面负责缓存和释放 VM；VM 自己只处理当前频道的数据状态。
class ChannelTabVM extends BaseVM<ChannelTabUS> {
  ChannelTabVM({required ChannelTab tab})
    : super(ChannelTabUS.initial(channelId: tab.id, title: tab.title));

  bool _loaded = false;

  Future<void> loadOnce() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    await Future<void>.delayed(const Duration(milliseconds: 220));
    safeEmit(
      state.copyWith(
        loadCount: state.loadCount + 1,
        items: List<String>.generate(
          18,
          (index) => '${state.title} 内容 ${index + 1}',
        ),
      ),
    );
  }

  void increaseTouchCount() {
    safeEmit(state.copyWith(touchCount: state.touchCount + 1));
  }
}
