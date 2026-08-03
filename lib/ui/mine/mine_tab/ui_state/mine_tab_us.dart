import '../../../../shared/model/domain_summary.dart';

/// 个人中心 tab 的 UIState。
class MineTabUS {
  const MineTabUS({
    required this.isLoading,
    required this.summary,
    required this.errorMessage,
  });

  const MineTabUS.initial()
    : isLoading = true,
      summary = null,
      errorMessage = null;

  final bool isLoading;
  final DomainSummary? summary;
  final String? errorMessage;

  MineTabUS copyWith({
    bool? isLoading,
    DomainSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MineTabUS(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
