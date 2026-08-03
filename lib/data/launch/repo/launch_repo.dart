import '../../../app/app_runtime.dart';
import '../../common/network/api_result.dart';
import '../ds/launch_rds.dart';

/// Flutter 启动业务页使用的启动配置。
class LaunchConfig {
  const LaunchConfig({
    required this.enableSplashAd,
    required this.minShowMillis,
    required this.targetPath,
  });

  factory LaunchConfig.fromJson(Map<String, Object?>? json) {
    if (json == null || json.isEmpty) {
      return LaunchConfig(
        enableSplashAd: false,
        minShowMillis: 0,
        targetPath: '',
      );
    }
    return LaunchConfig(
      enableSplashAd: json['enableSplashAd'] as bool? ?? false,
      minShowMillis: json['minShowMillis'] as int? ?? 0,
      targetPath: json['targetPath'] as String? ?? '/home',
    );
  }

  final bool enableSplashAd;
  final int minShowMillis;
  final String targetPath;
}

abstract interface class LaunchRepoContract {
  Future<ApiResult<LaunchConfig>> fetchLaunchConfig();
}

/// 启动数据仓库。
class LaunchRepo implements LaunchRepoContract {
  LaunchRepo() : _rds = LaunchRds(AppRuntime.instance.apiClient);

  final LaunchRds _rds;

  @override
  Future<ApiResult<LaunchConfig>> fetchLaunchConfig() async {
    final result = await _rds.fetchLaunchConfigJson();
    return result.mapResult(LaunchConfig.fromJson);
  }
}
