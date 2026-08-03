/// 固定关注子 tab 的 UIState。
class FixedFollowTabUS {
  const FixedFollowTabUS({
    required this.tabName,
    required this.loadCount,
    required this.clickCount,
    required this.items,
  });

  factory FixedFollowTabUS.initial(String tabName) {
    return FixedFollowTabUS(
      tabName: tabName,
      loadCount: 0,
      clickCount: 0,
      items: const [],
    );
  }

  final String tabName;
  final int loadCount;
  final int clickCount;
  final List<String> items;

  FixedFollowTabUS copyWith({
    int? loadCount,
    int? clickCount,
    List<String>? items,
  }) {
    return FixedFollowTabUS(
      tabName: tabName,
      loadCount: loadCount ?? this.loadCount,
      clickCount: clickCount ?? this.clickCount,
      items: items ?? this.items,
    );
  }
}
