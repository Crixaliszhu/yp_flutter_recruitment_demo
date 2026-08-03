import '../../common/network/api_client.dart';
import '../../common/network/api_result.dart';

/// 消息远程数据源。
class MessageRds {
  const MessageRds(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<Map<String, Object?>>> fetchSummaryJson() {
    return _apiClient.getJson(
      '/message/summary',
      headers: {'X-Biz-Domain': 'message'},
    );
  }
}
