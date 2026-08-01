import '../../../core/network/api_client.dart';
import '../../../shared/domain/domain_summary.dart';
import '../domain/message_repository.dart';

/// 消息域 Repository 实现。
///
/// 真实项目中这里可以接 HTTP、长连接缓存或原生推送通道。
class MessageRepositoryImpl implements MessageRepository {
  const MessageRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DomainSummary> fetchSummary() async {
    final result = await _apiClient.getJson('/message/summary');
    return DomainSummary.fromJson(result.requireData());
  }
}
