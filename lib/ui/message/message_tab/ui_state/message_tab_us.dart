import '../../../../shared/model/domain_summary.dart';

/// 消息 tab 的 UIState。
class MessageTabUS {
  const MessageTabUS({
    required this.isLoading,
    required this.summary,
    required this.errorMessage,
  });

  const MessageTabUS.initial()
    : isLoading = true,
      summary = null,
      errorMessage = null;

  final bool isLoading;
  final DomainSummary? summary;
  final String? errorMessage;

  MessageTabUS copyWith({
    bool? isLoading,
    DomainSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessageTabUS(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
