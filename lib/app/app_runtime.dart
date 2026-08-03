import '../adapter/splash_ad/splash_ad_adapter.dart';
import '../data/common/network/api_client.dart';
import '../data/common/network/network_loading_controller.dart';
import '../data/common/storage/key_value_storage.dart';

/// 应用运行时基础能力。
///
/// 这里只保存网络、存储、原生适配器等底层能力，不登记页面、VM、Repo 或 UseCase。
/// 页面依赖由页面自己决定，业务对象由对应 VM 自行创建。
class AppRuntime {
  AppRuntime._({
    required this.storage,
    required this.apiClient,
    required this.splashAdAdapter,
    required this.loadingController,
  });

  static AppRuntime? _instance;

  final KeyValueStorage storage;
  final ApiClient apiClient;
  final SplashAdAdapter splashAdAdapter;
  final NetworkLoadingController loadingController;

  static AppRuntime get instance {
    final runtime = _instance;
    assert(runtime != null, 'AppRuntime 尚未初始化，请先执行 AppBootstrap.init()');
    return runtime!;
  }

  static void init({
    required KeyValueStorage storage,
    required ApiClient apiClient,
    required SplashAdAdapter splashAdAdapter,
    required NetworkLoadingController loadingController,
  }) {
    _instance = AppRuntime._(
      storage: storage,
      apiClient: apiClient,
      splashAdAdapter: splashAdAdapter,
      loadingController: loadingController,
    );
  }
}
