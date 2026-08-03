import 'package:flutter/material.dart';

import '../model/domain_summary.dart';

/// 通用异步 tab 页面骨架。
///
/// 这里只处理加载态和摘要面板；业务卡片仍由各 UI 域传入，避免 shared 组件感知业务细节。
class AsyncDomainPage extends StatelessWidget {
  const AsyncDomainPage({
    super.key,
    required this.title,
    required this.isLoading,
    required this.summary,
    required this.errorMessage,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.children,
  });

  final String title;
  final bool isLoading;
  final DomainSummary? summary;
  final String? errorMessage;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: false),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final message = errorMessage;
    if (message != null) {
      return Center(child: Text(message));
    }

    final data = summary;
    if (data == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryPanel(summary: data),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onPrimaryAction,
          icon: const Icon(Icons.open_in_new),
          label: Text(primaryActionLabel),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.summary});

  final DomainSummary summary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Icon(
                  summary.authed ? Icons.verified_user : Icons.lock_open,
                  size: 20,
                  color: summary.authed ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(summary.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final badge in summary.badges)
                  Chip(
                    label: Text(badge),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
