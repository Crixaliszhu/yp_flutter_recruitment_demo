import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../ui_state/launch_us.dart';
import '../view_model/launch_vm.dart';

/// Flutter 启动业务页。
///
/// 原生 LaunchTheme/LaunchScreen 只覆盖 Flutter 首帧前的空窗期；Flutter 就绪后，
/// 启动路由分发、启动配置和广告兜底状态都由该页面承接。
class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  late final LaunchVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = LaunchVM();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _vm.close();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      await _vm.start();
    } on StateError {
      // 页面已销毁后异步启动流程返回时，Cubit 可能已经关闭；这里兜底吞掉生命周期竞争。
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LaunchVM, LaunchUS>(
      bloc: _vm,
      listenWhen: (previous, current) {
        return previous.targetPath != current.targetPath &&
            current.targetPath != null;
      },
      listener: (context, uiState) => context.go(uiState.targetPath!),
      child: BlocBuilder<LaunchVM, LaunchUS>(
        bloc: _vm,
        builder: (context, uiState) {
          return Scaffold(
            backgroundColor: const Color(0xFF1677FF),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            uiState.canSkip ? () => context.go('/home') : null,
                        child: const Text('跳过'),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.work, color: Colors.white, size: 72),
                    const SizedBox(height: 24),
                    Text(
                      uiState.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      uiState.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const LinearProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Color(0x553B9CFF),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
