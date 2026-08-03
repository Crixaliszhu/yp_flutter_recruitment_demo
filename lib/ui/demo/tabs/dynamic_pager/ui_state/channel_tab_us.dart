/// 动态频道子页的 UIState。
class ChannelTabUS {
  const ChannelTabUS({
    required this.channelId,
    required this.title,
    required this.loadCount,
    required this.touchCount,
    required this.items,
  });

  factory ChannelTabUS.initial({
    required String channelId,
    required String title,
  }) {
    return ChannelTabUS(
      channelId: channelId,
      title: title,
      loadCount: 0,
      touchCount: 0,
      items: const [],
    );
  }

  final String channelId;
  final String title;
  final int loadCount;
  final int touchCount;
  final List<String> items;

  ChannelTabUS copyWith({
    int? loadCount,
    int? touchCount,
    List<String>? items,
  }) {
    return ChannelTabUS(
      channelId: channelId,
      title: title,
      loadCount: loadCount ?? this.loadCount,
      touchCount: touchCount ?? this.touchCount,
      items: items ?? this.items,
    );
  }
}
