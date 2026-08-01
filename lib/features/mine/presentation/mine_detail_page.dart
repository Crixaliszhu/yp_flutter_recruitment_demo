import 'package:flutter/material.dart';

import '../../../shared/presentation/scene_card.dart';
import '../domain/mine_use_case.dart';

/// 个人中心域二级页。
///
/// 这里用角色切换演示“页面 -> UseCase -> Repository -> Storage”的完整调用链。
class MineDetailPage extends StatefulWidget {
  const MineDetailPage({super.key, required this.useCase});

  final MineUseCase useCase;

  @override
  State<MineDetailPage> createState() => _MineDetailPageState();
}

class _MineDetailPageState extends State<MineDetailPage> {
  String _role = '求职者';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心二级页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SceneCard(
            icon: Icons.manage_accounts_outlined,
            title: '业务域：account/mine',
            body: '这里演示角色切换、简历完善、认证状态和账号设置等个人中心二级流程。',
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '求职者', label: Text('求职者')),
              ButtonSegment(value: '招聘者', label: Text('招聘者')),
            ],
            selected: {_role},
            onSelectionChanged: (values) async {
              final next = await widget.useCase.switchRole(values.first);
              setState(() => _role = next);
            },
          ),
          const SizedBox(height: 12),
          Text('当前角色已写入本地存储：$_role'),
        ],
      ),
    );
  }
}
