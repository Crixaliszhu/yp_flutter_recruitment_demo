import '../adapter/splash_ad/splash_ad_adapter.dart';
import '../data/common/network/api_client.dart';
import '../data/common/network/network_loading_controller.dart';
import '../data/common/storage/key_value_storage.dart';
import '../ui/core/toast/app_toast.dart';
import 'app_runtime.dart';

/// 应用启动装配器。
///
/// 这里只初始化跨业务域共享的基础运行时能力，不登记页面和 VM。
/// 每个页面需要什么依赖，由页面和对应 VM 自行确定。
class AppBootstrap {
  const AppBootstrap._();

  static Future<void> init() async {
    final storage = await KeyValueStorage.create();
    // 模拟原生容器在启动 Flutter 前注入登录态；真实项目可来自 MethodChannel/Pigeon。
    await storage.setString(StorageKeys.accessToken, 'mock-token-from-native');
    final loadingController = NetworkLoadingController(
      onShow: () => AppToast.showLoading(),
      onDismiss: AppToast.hideLoading,
    );

    final apiClient = ApiClient(
      baseUrl: 'https://mock.recruitment.yupao.local',
      tokenProvider: () => storage.getString(StorageKeys.accessToken),
      loadingController: loadingController,
    );

    AppRuntime.init(
      storage: storage,
      apiClient: apiClient,
      splashAdAdapter: const SplashAdAdapter(),
      loadingController: loadingController,
    );
  }
}
