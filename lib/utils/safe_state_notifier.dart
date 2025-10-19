import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [`StateNotifier`] that defers state notifications when Flutter is still
/// building the widget tree. This prevents Riverpod from throwing
/// "Tried to modify a provider while the widget tree was building" while
/// keeping updates synchronous in all other scenarios.
abstract class SafeStateNotifier<T> extends StateNotifier<T> {
  SafeStateNotifier(T state)
      : _stateCache = state,
        super(state);

  T _stateCache;
  T? _pendingNotification;
  bool _notificationScheduled = false;

  @override
  T get state => _stateCache;

  @override
  set state(T value) {
    _stateCache = value;

    final binding = SchedulerBinding.instance;
    final phase = binding.schedulerPhase;

    // Delay notifications only while Flutter is executing persistent callbacks
    // (i.e. building/layout/paint). In all other phases we can notify
    // listeners immediately.
    final shouldDelay = phase == SchedulerPhase.persistentCallbacks;

    if (!shouldDelay || !mounted) {
      super.state = value;
      return;
    }

    _pendingNotification = value;
    if (_notificationScheduled) {
      return;
    }

    _notificationScheduled = true;
    binding.addPostFrameCallback((_) {
      _notificationScheduled = false;
      if (!mounted) {
        return;
      }
      final pending = _pendingNotification;
      _pendingNotification = null;
      if (pending == null) {
        return;
      }
      super.state = pending;
    });
  }
}
