import 'dart:isolate';

import 'model/isolate_demo_models.dart';

/// 计算小于等于 max 的质数数量与求和。
///
/// 该函数必须是顶层函数或静态函数，才能安全传给 Isolate.run/Isolate.spawn。
PrimeSumResult calculatePrimeSum(PrimeSumTask task) {
  final watch = Stopwatch()..start();
  var count = 0;
  var sum = 0;
  for (var value = 2; value <= task.max; value++) {
    if (_isPrime(value)) {
      count += 1;
      sum += value;
    }
  }
  watch.stop();
  return PrimeSumResult(
    max: task.max,
    primeCount: count,
    sum: sum,
    elapsedMillis: watch.elapsedMilliseconds,
  );
}

/// 长驻 worker isolate 入口。
///
/// 主 isolate 先传入一个 SendPort，worker 创建自己的 ReceivePort 后把 SendPort 回传。
/// 后续主 isolate 就能不断把 WorkerRequest 投递给这个 worker。
void primeWorkerEntry(SendPort mainSendPort) {
  final workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort);

  workerReceivePort.listen((message) {
    if (message == 'close') {
      workerReceivePort.close();
      return;
    }

    final request = message as WorkerRequest;
    final result = calculatePrimeSum(PrimeSumTask(max: request.max));
    request.replyPort.send(WorkerResponse(id: request.id, result: result));
  });
}

bool _isPrime(int value) {
  if (value < 2) {
    return false;
  }
  if (value == 2) {
    return true;
  }
  if (value.isEven) {
    return false;
  }
  for (var factor = 3; factor * factor <= value; factor += 2) {
    if (value % factor == 0) {
      return false;
    }
  }
  return true;
}
