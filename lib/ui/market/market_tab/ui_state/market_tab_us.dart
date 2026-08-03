import '../../../../shared/model/domain_summary.dart';

/// 集市 tab 的 UIState。
class MarketTabUS {
  const MarketTabUS({
    required this.isLoading,
    required this.summary,
    required this.errorMessage,
  });

  const MarketTabUS.initial()
    : isLoading = true,
      summary = null,
      errorMessage = null;

  final bool isLoading;
  final DomainSummary? summary;
  final String? errorMessage;

  MarketTabUS copyWith({
    bool? isLoading,
    DomainSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MarketTabUS(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
