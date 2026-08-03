/// 个人中心二级页的 UIState。
class MineDetailUS {
  const MineDetailUS({required this.role});

  final String role;

  MineDetailUS copyWith({String? role}) {
    return MineDetailUS(role: role ?? this.role);
  }
}
