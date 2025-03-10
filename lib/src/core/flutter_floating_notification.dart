import 'dart:async';

import 'package:flutter/material.dart';

import 'floating_bar_content.dart';
import 'floating_functions.dart';
import 'floating_gesture_direction.dart';

/// 浮动通知队列对象
class FlutterFloatNotification {
  FlutterFloatNotification();

  static final FlutterFloatNotification _global = FlutterFloatNotification();

  /// 全局浮动通知队列对象
  static FlutterFloatNotification global() => _global;

  final List<OverlayEntry> _flushEntryList = <OverlayEntry>[];

  bool _isFlushShowing = false;

  void _overlayInsert(BuildContext context, OverlayEntry entry) {
    try {
      Overlay.of(context).insert(entry);
    } catch (e) {
      debugPrint('_overlayInsert error: $e');
    }
  }

  /// 显示浮动通知
  Future<T?> showFloatingBar<T extends Object?>(
    BuildContext context, {
    required FlushContentBuilder<T> childBuilder,
    Duration? animationDuration,
    Curve? animationCurve,
    Duration? duration,
    bool? indefinite,
    double? height,
    OnFlushTap<T>? onTap,
    FloatingGestureDirection direction = FloatingGestureDirection.all,
  }) async {
    OverlayEntry? entry;
    final Completer<T?> completer = Completer<T?>();

    entry = OverlayEntry(
      builder: (BuildContext context) => FlushBarContent<T>(
        childBuilder: childBuilder,
        duration: duration ?? const Duration(seconds: 2),
        indefinite: indefinite ?? false,
        animationDuration:
            animationDuration ?? const Duration(milliseconds: 500),
        animationCurve: animationCurve ?? Curves.ease,
        height: height,
        onTap: onTap,
        direction: direction,
        onDismissed: (T? value) {
          completer.complete(value);
          _next(context);
        },
      ),
    );

    _flushEntryList.add(entry);

    if (!_isFlushShowing) {
      _show(context, _flushEntryList.first);
    }

    return completer.future;
  }

  void _show(BuildContext context, OverlayEntry entry) {
    _isFlushShowing = true;
    Future<void>.microtask(() => _overlayInsert(context, entry));
  }

  void _next(BuildContext context) {
    if (_flushEntryList.isNotEmpty) {
      _flushEntryList.first.remove();
      _flushEntryList.removeAt(0);
    }

    if (_flushEntryList.isEmpty) {
      _isFlushShowing = false;
    } else {
      _show(context, _flushEntryList.first);
    }
  }

  /// 清空浮动通知
  void clear() {
    for (final OverlayEntry entry in _flushEntryList) {
      entry.remove();
    }
    _isFlushShowing = false;
    _flushEntryList.clear();
  }
}
