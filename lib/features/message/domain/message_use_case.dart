import '../../../shared/domain/domain_summary.dart';
import 'message_repository.dart';

/// 消息域业务用例。
///
/// 用于隔离推送 payload、会话跳转、未读状态同步等跨端交互逻辑。
class MessageUseCase {
  const MessageUseCase(this._repository);

  final MessageRepository _repository;

  Future<DomainSummary> loadSummary() {
    return _repository.fetchSummary();
  }
}
