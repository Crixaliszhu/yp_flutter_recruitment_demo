/// 网络层返回值包装。
///
/// 用显式的 success/failure 替代页面层到处 try/catch，后续也方便扩展错误码、
/// toast 策略、登录失效处理等大型项目常见能力。
class ApiResult<T> {
  const ApiResult._({this.data, this.error, this.stackTrace});

  const ApiResult.success(T data) : this._(data: data);

  const ApiResult.failure(Object error, StackTrace stackTrace)
    : this._(error: error, stackTrace: stackTrace);

  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isSuccess => error == null;

  T requireData() {
    final value = data;
    if (value == null) {
      throw StateError('ApiResult has no data: $error');
    }
    return value;
  }
}
