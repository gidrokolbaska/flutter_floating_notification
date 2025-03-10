import 'dart:async';

import 'package:flutter/material.dart';

import 'floating_bar_content.dart';
import 'floating_functions.dart';
import 'floating_gesture_direction.dart';

/// 浮动通知队列对象
class FlutterFloatNotification {
  static final FlutterFloatNotification _singleton =
      FlutterFloatNotification._internal();

  factory FlutterFloatNotification() {
    return _singleton;
  }

  FlutterFloatNotification._internal();

  final List<OverlayEntry> _flushEntryList = <OverlayEntry>[];

  void _overlayInsert(BuildContext context, OverlayEntry entry) {
    try {
      Overlay.of(context).insert(entry);
      _flushEntryList.add(entry);
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

    _show(context, entry);

    return completer.future;
  }

  void _show(BuildContext context, OverlayEntry entry) {
    Future<void>.microtask(() => _overlayInsert(context, entry));
  }

  void _next(BuildContext context) {
    if (_flushEntryList.isNotEmpty) {
      _flushEntryList.first.remove();
      _flushEntryList.removeAt(0);
    }
  }

  /// 清空浮动通知
  void clear() {
    for (final OverlayEntry entry in _flushEntryList) {
      entry.remove();
    }
    _flushEntryList.clear();
  }
}
