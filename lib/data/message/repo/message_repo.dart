import '../../../app/app_runtime.dart';
import '../../common/network/api_result.dart';
import '../../../shared/model/domain_summary.dart';
import '../ds/message_rds.dart';

abstract interface class MessageRepoContract {
  Future<ApiResult<DomainSummary>> fetchSummary();
}

/// 消息数据仓库。
class MessageRepo implements MessageRepoContract {
  MessageRepo() : _rds = MessageRds(AppRuntime.instance.apiClient);

  final MessageRds _rds;

  @override
  Future<ApiResult<DomainSummary>> fetchSummary() async {
    final result = await _rds.fetchSummaryJson();
    return result.mapResult((json) {
      if (json == null) {
        return null;
      }
      return DomainSummary.fromJson(json);
    });
  }
}
