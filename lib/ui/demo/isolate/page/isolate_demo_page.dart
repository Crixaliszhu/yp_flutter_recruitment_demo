import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import '../isolate_jobs.dart';
import '../model/isolate_demo_models.dart';

/// 多 Isolate 开发示例页。
///
/// 页面演示三件事：
/// 1. Microtask 与 Event 是同一个 isolate 事件循环里的两个独立队列。
/// 2. Isolate.run 适合一次性 CPU 计算，结果通过消息回到主 isolate。
/// 3. ReceivePort/SendPort 适合长驻 worker，主 isolate 可以反复投递任务。
class IsolateDemoPage extends StatefulWidget {
  const IsolateDemoPage({super.key});

  @override
  State<IsolateDemoPage> createState() => _IsolateDemoPageState();
}

class _IsolateDemoPageState extends State<IsolateDemoPage> {
  final List<String> _eventLogs = [];
  final List<String> _isolateLogs = [];

  Isolate? _worker;
  SendPort? _workerSendPort;
  ReceivePort? _workerInitPort;
  int _requestId = 0;
  bool _runningInMain = false;
  bool _runningInIsolateRun = false;
  bool _runningInWorker = false;

  @override
  void dispose() {
    _workerSendPort?.send('close');
    _worker?.kill(priority: Isolate.immediate);
    _workerInitPort?.close();
    super.dispose();
  }

  void _runEventLoopDemo() {
    setState(() {
      _eventLogs
        ..clear()
        ..add('同步代码：开始');
    });

    scheduleMicrotask(() => _appendEventLog('Microtask：scheduleMicrotask'));
    Future.microtask(() => _appendEventLog('Microtask：Future.microtask'));
    Future(() => _appendEventLog('Event：Future()'));
    Timer.run(() => _appendEventLog('Event：Timer.run'));

    _appendEventLog('同步代码：结束');
  }

  Future<void> _runOnMainIsolate() async {
    setState(() {
      _runningInMain = true;
      _isolateLogs.add('主 isolate CPU 计算开始，UI 会短暂失去响应');
    });

    final result = calculatePrimeSum(const PrimeSumTask(max: 90000));
    if (!mounted) {
      return;
    }
    setState(() {
      _runningInMain = false;
      _isolateLogs.add(_formatResult('主 isolate 计算完成', result));
    });
  }

  Future<void> _runWithIsolateRun() async {
    setState(() {
      _runningInIsolateRun = true;
      _isolateLogs.add('Isolate.run 投递任务，主 isolate 可以继续响应 UI');
    });

    final result = await Isolate.run(
      () => calculatePrimeSum(const PrimeSumTask(max: 160000)),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _runningInIsolateRun = false;
      _isolateLogs.add(_formatResult('Isolate.run 返回结果', result));
    });
  }

  Future<void> _runWithWorker() async {
    setState(() {
      _runningInWorker = true;
      _isolateLogs.add('长驻 worker 接收任务');
    });

    final workerPort = await _ensureWorkerPort();
    final replyPort = ReceivePort();
    final id = ++_requestId;
    workerPort.send(
      WorkerRequest(
        id: id,
        max: 140000 + id * 10000,
        replyPort: replyPort.sendPort,
      ),
    );

    final response = await replyPort.first as WorkerResponse;
    replyPort.close();
    if (!mounted) {
      return;
    }
    setState(() {
      _runningInWorker = false;
      _isolateLogs.add(
        _formatResult('worker #${response.id} 返回结果', response.result),
      );
    });
  }

  Future<SendPort> _ensureWorkerPort() async {
    final cachedPort = _workerSendPort;
    if (cachedPort != null) {
      return cachedPort;
    }

    _workerInitPort = ReceivePort();
    _worker = await Isolate.spawn(primeWorkerEntry, _workerInitPort!.sendPort);
    final port = await _workerInitPort!.first as SendPort;
    _workerSendPort = port;
    _workerInitPort?.close();
    _workerInitPort = null;
    return port;
  }

  void _appendEventLog(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _eventLogs.add(message);
    });
  }

  String _formatResult(String prefix, PrimeSumResult result) {
    return '$prefix：<= ${result.max}，质数 ${result.primeCount} 个，求和 ${result.sum}，耗时 ${result.elapsedMillis}ms';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('多 Isolate 开发示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoSection(
            title: 'Event 与 Microtask',
            description:
                'Microtask 和 Event 是同一个 isolate 事件循环里的两个独立队列；同步代码结束后先清空 Microtask，再处理 Event。',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _runEventLoopDemo,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('运行队列顺序示例'),
                ),
                const SizedBox(height: 12),
                _LogBox(logs: _eventLogs),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DemoSection(
            title: 'CPU 任务对比',
            description:
                'await 不会自动切 isolate。主 isolate 直接算会卡 UI；Isolate.run 会把顶层函数投递到新的 isolate 执行。',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _runningInMain ? null : _runOnMainIsolate,
                  icon: const Icon(Icons.warning_amber_outlined),
                  label: Text(
                    _runningInMain ? '主 isolate 计算中' : '在主 isolate 计算',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _runningInIsolateRun ? null : _runWithIsolateRun,
                  icon: const Icon(Icons.memory_outlined),
                  label: Text(
                    _runningInIsolateRun
                        ? 'Isolate.run 计算中'
                        : '使用 Isolate.run 计算',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _runningInWorker ? null : _runWithWorker,
                  icon: const Icon(Icons.sync_alt_outlined),
                  label: Text(_runningInWorker ? 'worker 计算中' : '投递给长驻 worker'),
                ),
                const SizedBox(height: 12),
                _LogBox(logs: _isolateLogs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

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
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LogBox extends StatelessWidget {
  const _LogBox({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(logs.isEmpty ? '暂无日志' : logs.join('\n')),
      ),
    );
  }
}
