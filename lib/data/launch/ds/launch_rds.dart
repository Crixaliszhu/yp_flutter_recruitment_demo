import '../../common/network/api_client.dart';
import '../../common/network/api_result.dart';

/// 启动远程数据源。
///
/// 生产项目中通常会请求启动配置、广告策略、隐私开关和深链路由信息。
class LaunchRds {
  const LaunchRds(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<Map<String, Object?>>> fetchLaunchConfigJson() {
    return _apiClient.getJson(
      '/launch/config',
      showLoading: false,
      headers: {'X-Biz-Domain': 'launch'},
    );
  }
}
