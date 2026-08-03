import 'package:flutter_bloc/flutter_bloc.dart';

/// Flutter 页面 ViewModel 的基础类。
///
/// 页面销毁后 VM 会被 close，如果异步任务稍后返回并继续 emit，Bloc 会抛出异常。
/// 业务 VM 统一通过 safeEmit 更新 UIState，避免每个请求完成后重复书写 isClosed 判断。
abstract class BaseVM<S> extends Cubit<S> {
  BaseVM(super.initialState);

  /// 安全发送 UIState。
  ///
  /// safeEmit 只负责拦截已关闭 VM 的状态更新；如果异步流程后续还有路由、弹窗、
  /// 广告等待等副作用，业务方法仍应按需判断 isClosed 后再继续执行。
  void safeEmit(S state) {
    if (isClosed) {
      return;
    }
    emit(state);
  }
}
