import '../core/network/api_client.dart';
import '../core/storage/key_value_storage.dart';
import '../features/home/data/home_repository_impl.dart';
import '../features/home/domain/home_use_case.dart';
import '../features/market/data/market_repository_impl.dart';
import '../features/market/domain/market_use_case.dart';
import '../features/message/data/message_repository_impl.dart';
import '../features/message/domain/message_use_case.dart';
import '../features/mine/data/mine_repository_impl.dart';
import '../features/mine/domain/mine_use_case.dart';
import 'app_dependencies.dart';

/// 应用启动装配器。
///
/// 大型项目里通常由 DI 框架、原生启动参数或远程配置参与初始化。demo 用手写
/// 方式显式展示依赖方向：storage/network -> repository -> use case -> page。
class AppBootstrap {
  const AppBootstrap._();

  static Future<AppDependencies> create() async {
    final storage = await KeyValueStorage.create();
    // 模拟原生容器在启动 Flutter 前注入登录态；真实项目可来自 MethodChannel/Pigeon。
    await storage.setString(StorageKeys.accessToken, 'mock-token-from-native');

    final apiClient = ApiClient(
      baseUrl: 'https://mock.recruitment.yupao.local',
      tokenProvider: () => storage.getString(StorageKeys.accessToken),
    );

    return AppDependencies(
      storage: storage,
      apiClient: apiClient,
      homeUseCase: HomeUseCase(HomeRepositoryImpl(apiClient)),
      marketUseCase: MarketUseCase(MarketRepositoryImpl(apiClient)),
      messageUseCase: MessageUseCase(MessageRepositoryImpl(apiClient)),
      mineUseCase: MineUseCase(MineRepositoryImpl(apiClient, storage)),
    );
  }
}
