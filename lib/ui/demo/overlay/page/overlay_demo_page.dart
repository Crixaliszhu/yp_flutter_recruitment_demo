import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_runtime.dart';
import '../../../core/toast/app_toast.dart';

/// Overlay、Toast、Loading 和网络错误处理示例页。
class OverlayDemoPage extends StatefulWidget {
  const OverlayDemoPage({super.key});

  @override
  State<OverlayDemoPage> createState() => _OverlayDemoPageState();
}

class _OverlayDemoPageState extends State<OverlayDemoPage> {
  OverlayEntry? _entry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  Future<void> _showNetworkLoading() async {
    await AppRuntime.instance.apiClient.getJson(
      '/market/summary',
      headers: {'X-Demo': 'bot-toast-loading'},
      showLoading: true,
    );
  }

  Future<void> _requestErrorWithToast() async {
    await AppRuntime.instance.apiClient.getJson(
      '/demo/error',
      showLoading: true,
      allowErrorToast: true,
    );
  }

  Future<void> _requestErrorSilently() async {
    final result = await AppRuntime.instance.apiClient.getJson(
      '/demo/error',
      showLoading: false,
      allowErrorToast: false,
    );
    if (result.isOK()) {
      AppToast.showText('静默错误接口：${result.data}');
    }
  }

  void _showRawOverlay() {
    _removeOverlay();
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 24,
          right: 24,
          bottom: 96,
          child: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xE61D2733),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.layers_outlined, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '这是手动插入的 OverlayEntry，3 秒后自动移除。',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: _removeOverlay,
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: '关闭',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_entry!);
    unawaited(
      Future<void>.delayed(const Duration(seconds: 3)).then((_) {
        if (mounted) {
          _removeOverlay();
        }
      }),
    );
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overlay 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoButton(
            icon: Icons.chat_bubble_outline,
            title: '显示 BotToast 文本 Toast',
            subtitle: '使用 AppToast.showText，内部基于 BotToast Overlay。',
            onPressed: () => AppToast.showText('这是一条 BotToast 文本提示'),
          ),
          _DemoButton(
            icon: Icons.hourglass_top,
            title: '触发网络 Loading',
            subtitle: '请求 showLoading=true，Dio 拦截器会展示 BotToast loading 动画。',
            onPressed: _showNetworkLoading,
          ),
          _DemoButton(
            icon: Icons.error_outline,
            title: '请求错误并允许 Toast',
            subtitle: 'allowErrorToast=true，通用错误拦截器会弹出错误提示。',
            onPressed: _requestErrorWithToast,
          ),
          _DemoButton(
            icon: Icons.notifications_off_outlined,
            title: '请求错误但静默处理',
            subtitle: 'allowErrorToast=false，不重要接口失败时不打扰用户。',
            onPressed: _requestErrorSilently,
          ),
          _DemoButton(
            icon: Icons.layers_outlined,
            title: '手动插入 OverlayEntry',
            subtitle: '展示 Flutter 原生 Overlay 的插入和移除方式。',
            onPressed: _showRawOverlay,
          ),
        ],
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE6EAF0)),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onPressed,
        ),
      ),
    );
  }
}
