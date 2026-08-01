import '../../../shared/domain/domain_summary.dart';

/// 消息域的数据能力接口。
///
/// 后续可扩展会话列表、系统通知、红点状态等 IM 能力。
abstract interface class MessageRepository {
  Future<DomainSummary> fetchSummary();
}
