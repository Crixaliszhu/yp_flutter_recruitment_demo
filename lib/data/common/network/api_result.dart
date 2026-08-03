/// 网络层返回结果包装。
///
/// 页面和 VM 不应该到处写 try/catch；统一结果类型便于后续扩展错误码、登录失效和重试信息。
class ApiResult<T> {
  const ApiResult({this.success, this.fail});

  final ApiSuccess<T>? success;
  final ApiFail? fail;

  bool isOK() => success != null;

  bool get isFail => fail != null;

  /// 返回成功的数据
  T? getSuccess() => success?.data;

  /// 返回成功的数据，便于内部通用工具读取。
  T? get data => success?.data;

  /// 返回失败信息，便于内部通用工具读取。
  ApiFail? get error => fail;

  /// 收集接口返回数据，不改变返回数据类型
  ApiResult<T> collectResult(
    void Function(T?)? onSuccess,
    void Function(ApiFail?)? onFail,
  ) {
    if (isOK() && onSuccess != null) {
      onSuccess(getSuccess());
    } else if (isFail && onFail != null) {
      onFail(fail);
    }
    return this;
  }

  /// 提供返回数据类型变换
  ApiResult<R> mapResult<R>(Function(T?) transform) {
    if (isOK()) {
      return ApiSuccess.buildSuccess<R>(
        transform(getSuccess()),
        success?.message ?? "",
        success?.askId ?? "",
      );
    }
    return ApiFail.buildFail(
      fail?.message,
      fail?.askId,
      fail?.code,
      fail?.dialogModel,
    );
  }
}

/// 成功数据类型
class ApiSuccess<T> {
  const ApiSuccess({this.data, this.message, this.askId});

  /// 请求成功返回业务数据
  final T? data;

  /// 接口统一返回统一消息
  final String? message;

  /// 请求id方便后端问题排查
  final String? askId;

  /// 构造一个成功事件
  static ApiResult<T> buildSuccess<T>(T? data, String? message, String? askId) {
    return ApiResult(
      success: ApiSuccess(data: data, message: message, askId: askId),
    );
  }
}

/// 错误数据类型
class ApiFail {
  final String? message;
  final String? askId;

  /// 错误码
  final int? code;
  final BizDialogModel? dialogModel;

  ApiFail(this.message, this.askId, this.code, this.dialogModel);

  /// 构造失败数据
  static ApiResult<T> buildFail<T>(
    String? message,
    String? askId,
    int? code,
    BizDialogModel? dialogModel,
  ) {
    return ApiResult(fail: ApiFail(message, askId, code, dialogModel));
  }
}

/// 通用弹窗数据-接口报错时可能会返回弹窗数据
class BizDialogModel {
  final String? dialogIdentify;
  final Map<String, String> templates;

  BizDialogModel(this.dialogIdentify, this.templates);
}
