/// Flutter 启动业务页的 UIState。
class LaunchUS {
  const LaunchUS({
    required this.title,
    required this.description,
    required this.canSkip,
    required this.targetPath,
  });

  const LaunchUS.initial()
    : title = '渔泡招聘',
      description = '正在准备跨端业务环境',
      canSkip = false,
      targetPath = null;

  final String title;
  final String description;
  final bool canSkip;
  final String? targetPath;

  LaunchUS copyWith({
    String? title,
    String? description,
    bool? canSkip,
    String? targetPath,
  }) {
    return LaunchUS(
      title: title ?? this.title,
      description: description ?? this.description,
      canSkip: canSkip ?? this.canSkip,
      targetPath: targetPath ?? this.targetPath,
    );
  }
}
