import 'package:json_annotation/json_annotation.dart';

part 'domain_summary.g.dart';

/// 四个 tab 共同使用的摘要模型。
///
/// 真实业务专属模型应留在 `lib/data/{domain}`，这里只放 demo 共享展示所需的最小模型。
@JsonSerializable()
class DomainSummary {
  const DomainSummary({
    required this.title,
    required this.description,
    required this.badges,
    required this.authed,
  });

  factory DomainSummary.fromJson(Map<String, Object?> json) =>
      _$DomainSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$DomainSummaryToJson(this);

  final String title;
  final String description;
  final List<String> badges;
  final bool authed;
}
