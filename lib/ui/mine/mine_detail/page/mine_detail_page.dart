import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widget/scene_card.dart';
import '../ui_state/mine_detail_us.dart';
import '../view_model/mine_detail_vm.dart';

class MineDetailArgs {
  const MineDetailArgs({required this.section, required this.source});

  factory MineDetailArgs.fromQuery(Map<String, String> query) {
    return MineDetailArgs(
      section: query['section'] ?? 'profile',
      source: query['source'] ?? 'unknown',
    );
  }

  final String section;
  final String source;
}

/// 个人中心业务域二级页。
class MineDetailPage extends StatefulWidget {
  const MineDetailPage({super.key, required this.args});

  final MineDetailArgs args;

  @override
  State<MineDetailPage> createState() => _MineDetailPageState();
}

class _MineDetailPageState extends State<MineDetailPage> {
  late final MineDetailVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = MineDetailVM();
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MineDetailVM, MineDetailUS>(
      bloc: _vm,
      builder: (context, uiState) {
        return Scaffold(
          appBar: AppBar(title: const Text('个人中心二级页')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('模块参数：${widget.args.section}，来源：${widget.args.source}'),
              const SizedBox(height: 12),
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
                selected: {uiState.role},
                onSelectionChanged: (values) => _vm.switchRole(values.first),
              ),
              const SizedBox(height: 12),
              Text('当前角色已写入本地存储：${uiState.role}'),
            ],
          ),
        );
      },
    );
  }
}
