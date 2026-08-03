import '../../../../shared/model/domain_summary.dart';

/// 首页 tab 的 UIState。
class HomeTabUS {
  const HomeTabUS({
    required this.isLoading,
    required this.summary,
    required this.errorMessage,
  });

  const HomeTabUS.initial()
    : isLoading = true,
      summary = null,
      errorMessage = null;

  final bool isLoading;
  final DomainSummary? summary;
  final String? errorMessage;

  HomeTabUS copyWith({
    bool? isLoading,
    DomainSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeTabUS(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
