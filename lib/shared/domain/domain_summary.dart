/// 各业务域首页共用的摘要模型。
///
/// demo 中四个域都展示摘要卡片，因此抽到 shared；真实业务里更复杂的模型应留在
/// 各自 feature 内，避免 shared 变成无边界的大杂烩。
class DomainSummary {
  const DomainSummary({
    required this.title,
    required this.description,
    required this.badges,
    required this.authed,
  });

  factory DomainSummary.fromJson(Map<String, Object?> json) {
    return DomainSummary(
      title: json['title'] as String,
      description: json['description'] as String,
      badges: (json['badges'] as List<Object?>).cast<String>(),
      authed: json['authed'] as bool? ?? false,
    );
  }

  final String title;
  final String description;
  final List<String> badges;
  final bool authed;
}
