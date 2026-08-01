import '../../../shared/domain/domain_summary.dart';

/// 个人中心域的数据能力接口。
///
/// 用户资产、角色、认证和简历状态都应该从这里进入，避免页面散落读写本地缓存。
abstract interface class MineRepository {
  Future<DomainSummary> fetchSummary();
  Future<String> switchRole(String role);
}
