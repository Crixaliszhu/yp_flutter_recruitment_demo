import '../../../../app/app_runtime.dart';
import '../../../../adapter/splash_ad/splash_ad_adapter.dart';
import '../../../../data/launch/repo/launch_repo.dart';
import '../../../core/view_model/base_vm.dart';
import '../ui_state/launch_us.dart';

/// 启动页 ViewModel。
///
/// 原生静态启动页之后的启动业务归 Flutter 管。VM 负责启动配置和广告状态协调，
/// 但只返回目标路由，具体跳转仍由 Page 使用 BuildContext 完成。
class LaunchVM extends BaseVM<LaunchUS> {
  LaunchVM()
    : _repo = LaunchRepo(),
      _splashAdAdapter = AppRuntime.instance.splashAdAdapter,
      super(const LaunchUS.initial());

  final LaunchRepoContract _repo;
  final SplashAdAdapter _splashAdAdapter;

  Future<void> start() async {
    if (isClosed) {
      return;
    }
    safeEmit(state.copyWith(description: '正在读取启动配置'));
    final result = await _repo.fetchLaunchConfig();
    if (isClosed) {
      return;
    }
    final config =
        result.data ??
        const LaunchConfig(
          enableSplashAd: false,
          minShowMillis: 0,
          targetPath: '/home',
        );

    if (config.enableSplashAd) {
      safeEmit(state.copyWith(description: '正在等待原生开屏广告完成', canSkip: true));
      await _splashAdAdapter.waitForNativeSplashAdResult(
        fallbackMillis: config.minShowMillis,
      );
      if (isClosed) {
        return;
      }
    }

    final targetPath = config.targetPath.isEmpty ? '/home' : config.targetPath;
    safeEmit(state.copyWith(description: '即将进入首页', targetPath: targetPath));
  }
}
