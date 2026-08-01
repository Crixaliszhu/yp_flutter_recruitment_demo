import 'package:flutter/material.dart';

import '../domain/domain_summary.dart';

/// 业务域 tab 页的通用异步骨架。
///
/// 它只处理加载态和公共摘要区域，具体业务卡片仍由各 feature 传入，避免 shared
/// 组件知道太多业务细节。
class AsyncDomainPage extends StatelessWidget {
  const AsyncDomainPage({
    super.key,
    required this.title,
    required this.future,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.children,
  });

  final String title;
  final Future<DomainSummary> future;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: false),
      body: FutureBuilder<DomainSummary>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // 此处 demo 不展开错误态；生产项目建议统一接入失败页、重试和埋点。
          final summary = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryPanel(summary: summary),
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
        },
      ),
    );
  }
}

/// 摘要面板是 shared 内部组件，不向业务域暴露，减少公共 API 面积。
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
