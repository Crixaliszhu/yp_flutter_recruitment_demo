// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DomainSummary _$DomainSummaryFromJson(Map<String, dynamic> json) =>
    DomainSummary(
      title: json['title'] as String,
      description: json['description'] as String,
      badges:
          (json['badges'] as List<dynamic>).map((e) => e as String).toList(),
      authed: json['authed'] as bool,
    );

Map<String, dynamic> _$DomainSummaryToJson(DomainSummary instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'badges': instance.badges,
      'authed': instance.authed,
    };
