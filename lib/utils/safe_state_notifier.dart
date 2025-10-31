import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod 3 [`Notifier`] base class that defers state notifications
/// while the widget tree is rebuilding, mirroring the behaviour
/// previously implemented for [`StateNotifier`] controllers.
abstract class SafeNotifier<T> extends Notifier<T> {
  late T _stateCache;
  T? _pendingNotification;
  bool _notificationScheduled = false;
  bool _disposeHookRegistered = false;
  bool _isDisposed = false;

  bool get _isMounted => !_isDisposed;
  bool get isMounted => _isMounted;
  bool get isDisposed => _isDisposed;

  void _ensureDisposeHookRegistered() {
    if (_disposeHookRegistered) {
      return;
    }
    _disposeHookRegistered = true;
    ref.onDispose(() {
      _isDisposed = true;
      _pendingNotification = null;
      _notificationScheduled = false;
    });
  }

  @override
  T get state => _stateCache;

  @override
  set state(T value) {
    _ensureDisposeHookRegistered();
    _stateCache = value;

    final binding = SchedulerBinding.instance;
    final phase = binding.schedulerPhase;
    final shouldDelay = phase == SchedulerPhase.persistentCallbacks;

    if (!shouldDelay || !_isMounted) {
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
      if (!_isMounted) {
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

/// Auto-dispose counterpart of [SafeNotifier].
abstract class SafeAutoDisposeNotifier<T> extends AutoDisposeNotifier<T> {
  late T _stateCache;
  T? _pendingNotification;
  bool _notificationScheduled = false;
  bool _disposeHookRegistered = false;
  bool _isDisposed = false;

  bool get _isMounted => !_isDisposed;
  bool get isMounted => _isMounted;
  bool get isDisposed => _isDisposed;

  void _ensureDisposeHookRegistered() {
    if (_disposeHookRegistered) {
      return;
    }
    _disposeHookRegistered = true;
    ref.onDispose(() {
      _isDisposed = true;
      _pendingNotification = null;
      _notificationScheduled = false;
    });
  }

  @override
  T get state => _stateCache;

  @override
  set state(T value) {
    _ensureDisposeHookRegistered();
    _stateCache = value;

    final binding = SchedulerBinding.instance;
    final phase = binding.schedulerPhase;
    final shouldDelay = phase == SchedulerPhase.persistentCallbacks;

    if (!shouldDelay || !_isMounted) {
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
      if (!_isMounted) {
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
