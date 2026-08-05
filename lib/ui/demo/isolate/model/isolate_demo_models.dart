import 'dart:isolate';

/// Isolate.run 一次性计算任务的入参。
class PrimeSumTask {
  const PrimeSumTask({required this.max});

  final int max;
}

/// Isolate.run 一次性计算任务的结果。
class PrimeSumResult {
  const PrimeSumResult({
    required this.max,
    required this.primeCount,
    required this.sum,
    required this.elapsedMillis,
  });

  final int max;
  final int primeCount;
  final int sum;
  final int elapsedMillis;
}

/// 长驻 worker isolate 的请求消息。
class WorkerRequest {
  const WorkerRequest({
    required this.id,
    required this.max,
    required this.replyPort,
  });

  final int id;
  final int max;
  final SendPort replyPort;
}

/// 长驻 worker isolate 的响应消息。
class WorkerResponse {
  const WorkerResponse({required this.id, required this.result});

  final int id;
  final PrimeSumResult result;
}
