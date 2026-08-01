/// 本地 mock transport。
///
/// 它模拟后端按业务域返回摘要数据。保留这个层的意义是让 demo 的 Repository
/// 看起来和真实网络请求一致，之后切到真实接口时只改 transport/client。
class MockApiTransport {
  const MockApiTransport();

  Future<Map<String, Object?>> get(
    String path, {
    required Map<String, Object?> headers,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    // 用 Authorization 是否存在来模拟“原生已注入登录态”的跨端启动场景。
    final authed = headers['Authorization']?.toString().isNotEmpty ?? false;

    return switch (path) {
      '/home/summary' => {
        'title': '首页工作台',
        'description': '聚合推荐职位、待办跟进、最近沟通，像 recruitment_android 的 main/yupao 域。',
        'badges': ['推荐职位 18', '待跟进 4', '同城急招 7'],
        'authed': authed,
      },
      '/market/summary' => {
        'title': '集市供需',
        'description': '独立 marketplace 业务域，负责岗位交易、服务包、曝光资源。',
        'badges': ['曝光包', '找工人', '招工发布'],
        'authed': authed,
      },
      '/message/summary' => {
        'title': '消息中心',
        'description': 'IM 与通知域，隔离会话列表、系统通知、红点同步。',
        'badges': ['未读 12', '系统通知 3', '招聘顾问'],
        'authed': authed,
      },
      '/mine/summary' => {
        'title': '个人中心',
        'description': '账号、角色、简历、认证等用户资产聚合域。',
        'badges': ['已登录', '简历 82%', '实名待完善'],
        'authed': authed,
      },
      _ => throw StateError('No mock response registered for $path'),
    };
  }
}
