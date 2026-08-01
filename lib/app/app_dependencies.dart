import '../core/network/api_client.dart';
import '../core/storage/key_value_storage.dart';
import '../features/home/domain/home_use_case.dart';
import '../features/market/domain/market_use_case.dart';
import '../features/message/domain/message_use_case.dart';
import '../features/mine/domain/mine_use_case.dart';

/// 应用级依赖容器。
///
/// 这个 demo 不引入 get_it/riverpod 等框架，目的是让分层关系更直观。真实大型项目
/// 可以把此类替换为 DI 容器，但页面仍应依赖 UseCase 或领域服务，而非直接依赖 Dio。
class AppDependencies {
  const AppDependencies({
    required this.storage,
    required this.apiClient,
    required this.homeUseCase,
    required this.marketUseCase,
    required this.messageUseCase,
    required this.mineUseCase,
  });

  final KeyValueStorage storage;
  final ApiClient apiClient;
  final HomeUseCase homeUseCase;
  final MarketUseCase marketUseCase;
  final MessageUseCase messageUseCase;
  final MineUseCase mineUseCase;
}
