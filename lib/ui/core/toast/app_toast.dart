import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

/// 应用 Toast 与 Loading 统一入口。
///
/// 业务层不要直接调用 BotToast，后续替换样式或三方库时只需要改这里。
class AppToast {
  AppToast._();

  static CancelFunc? _loadingCancel;

  static CancelFunc showText(String message, {Duration? duration}) {
    if (message.isEmpty) {
      return () {};
    }
    return BotToast.showCustomText(
      onlyOne: true,
      crossPage: true,
      duration: duration ?? const Duration(seconds: 2),
      align: Alignment.center,
      wrapToastAnimation: (controller, cancel, child) {
        return FadeTransition(opacity: controller, child: child);
      },
      toastBuilder: (_) => _ToastContent(text: message),
    );
  }

  static void showLoading({String? text}) {
    if (_loadingCancel != null) {
      return;
    }
    _loadingCancel = BotToast.showCustomLoading(
      crossPage: true,
      allowClick: false,
      clickClose: false,
      backgroundColor: Colors.transparent,
      toastBuilder: (_) => _LoadingContent(text: text ?? '加载中...'),
    );
  }

  static void hideLoading() {
    _loadingCancel?.call();
    _loadingCancel = null;
  }

  static void cleanAll() {
    BotToast.cleanAll();
    _loadingCancel = null;
  }
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 132,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
