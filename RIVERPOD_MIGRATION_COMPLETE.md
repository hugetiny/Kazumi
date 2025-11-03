# Riverpod 3.x 迁移完成报告

## 📋 概述

**日期**: 2025-11-02
**状态**: ✅ **完成**
**编译状态**: ✅ **无错误**

本次迁移将项目中所有不推荐的 Riverpod Provider 类型更新到 Riverpod 3.x 推荐的最佳实践。

---

## 🎯 迁移内容

### 1. ❌ 删除废弃的 ChangeNotifier

**删除文件**:
- `lib/bean/settings/theme_provider.dart`

**原因**:
- Riverpod 官方不再推荐使用 `ChangeNotifier`
- 该文件已被 `lib/pages/setting/providers.dart` 中的 `ThemeNotifier` 替代
- `ThemeNotifier extends Notifier<ThemeState>` 是正确的 Riverpod 3.x 实现

### 2. ✅ StateNotifierProvider → NotifierProvider

**迁移文件**: `lib/providers/media_suite_providers.dart`

#### 变更前:
```dart
class TorrentConsentNotifier extends StateNotifier<TorrentConsentState> {
  TorrentConsentNotifier() : super(_initialState());

  static TorrentConsentState _initialState() {
    // ... 初始化逻辑
  }
}

final torrentConsentProvider =
    StateNotifierProvider<TorrentConsentNotifier, TorrentConsentState>((ref) {
  return TorrentConsentNotifier();
});
```

#### 变更后:
```dart
class TorrentConsentNotifier extends Notifier<TorrentConsentState> {
  @override
  TorrentConsentState build() {
    // ... 初始化逻辑直接在 build 中
    return TorrentConsentState(granted: granted, timestamp: timestamp);
  }
}

final torrentConsentProvider =
    NotifierProvider<TorrentConsentNotifier, TorrentConsentState>(
  TorrentConsentNotifier.new,
);
```

**优势**:
- ✅ 符合 Riverpod 3.x 最佳实践
- ✅ `build()` 方法替代构造函数，更清晰的初始化语义
- ✅ 使用 `.new` 语法，更简洁

### 3. ℹ️ StateProvider 保持原样

**保留的 StateProvider** (35 个):

#### 原因说明:
根据 [Riverpod 官方文档](https://riverpod.dev/docs/concepts/providers#stateprovider)，**StateProvider 仍然推荐用于简单的 UI 状态**，例如:
- Boolean flags（显示/隐藏状态）
- Counters（简单计数器）
- Selected indexes（选中索引）
- Simple form fields（简单表单字段）

#### 保留的使用场景:

**UI 控制状态** (适合 StateProvider):
```dart
// ✅ 推荐保留 - 简单的 UI 开关
final favoritesShowDeleteProvider = StateProvider.autoDispose<bool>((ref) => false);
final showDebugLogProvider = StateProvider.autoDispose<bool>((ref) => false);
final webdavPasswordVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);

// ✅ 推荐保留 - 简单的选择/索引
final selectedEpisodeProvider = StateProvider.autoDispose<int?>((ref) => null);
final currentRoadProvider = StateProvider.autoDispose<int>((ref) => 0);
final chartTouchedIndexProvider = StateProvider.autoDispose<int>((ref) => -1);

// ✅ 推荐保留 - 简单的列表/字符串
final webviewLogLinesProvider = StateProvider.autoDispose<List<String>>((ref) => []);
final logFileContentProvider = StateProvider.autoDispose<String>((ref) => '');
```

**设置页面状态** (适合 StateProvider):
```dart
final hardwareDecoderProvider = StateProvider.autoDispose<String>((ref) { ... });
final superResolutionTypeProvider = StateProvider.autoDispose<String>((ref) { ... });
final exitBehaviorProvider = StateProvider.autoDispose<int>((ref) { ... });
```

#### 何时应该迁移 StateProvider？

只有在以下情况才需要迁移到 Notifier:
- ❗ 状态有复杂的业务逻辑
- ❗ 需要多个字段组合（应使用 freezed class）
- ❗ 状态变更需要副作用（API 调用、持久化等）
- ❗ 需要从其他 provider 读取数据

**当前项目的 StateProvider 都是简单 UI 状态，保持原样是正确的。**

---

## 📊 迁移统计

| 类型 | 迁移前 | 迁移后 | 说明 |
|------|--------|--------|------|
| **ChangeNotifier** | 1 个 | 0 个 | ✅ 已删除废弃文件 |
| **StateNotifierProvider** | 1 个 | 0 个 | ✅ 已迁移到 NotifierProvider |
| **StateProvider** | 35 个 | 35 个 | ℹ️ 保留（符合官方推荐） |
| **NotifierProvider** | 已存在 | +1 个 | ✅ 新增 torrentConsentProvider |

---

## ✅ 验证结果

### 编译检查
```bash
flutter analyze --no-preamble
# Result: No issues found! ✅
```

### 代码质量
- ✅ 0 编译错误
- ✅ 0 类型错误
- ✅ 符合 Riverpod 3.x 最佳实践

---

## 📚 最佳实践总结

### ✅ 推荐使用 Notifier/NotifierProvider

**适用场景**:
- 复杂状态管理
- 需要业务逻辑
- 需要从其他 provider 读取数据
- 需要 lifecycle hooks (build, dispose)

```dart
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() {
    // 初始化逻辑
    return MyState.initial();
  }

  void updateSomething() {
    state = state.copyWith(field: newValue);
  }
}

final myProvider = NotifierProvider<MyNotifier, MyState>(
  MyNotifier.new,
);
```

### ✅ 推荐使用 StateProvider

**适用场景**:
- 简单的 UI 状态（boolean, int, String）
- 无业务逻辑
- 不需要从其他 provider 读取数据

```dart
// ✅ 适合 StateProvider
final counterProvider = StateProvider<int>((ref) => 0);
final isVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);
```

### ❌ 不推荐使用

1. **ChangeNotifier/ChangeNotifierProvider** - 已废弃
2. **StateNotifier/StateNotifierProvider** - 已被 Notifier 替代
3. **FutureProvider** - 使用 AsyncNotifierProvider 替代
4. **StreamProvider** - 使用 StreamNotifierProvider 替代

---

## 🚫 避免在 Widget 生命周期中修改 Provider

在以下生命周期内修改 Provider 容易触发运行时异常：
- build
- initState
- dispose
- didUpdateWidget
- didChangeDependencies

典型报错：

```
FlutterError (Tried to modify a provider while the widget tree was building.)
```

推荐做法：
- 持久化设置的初始化放到 Notifier.build() 中从存储读取（如 playerSettingsProvider）
- 仅在用户交互回调（onPressed/onChanged 等）中修改 Provider
- 如确需在页面入场时初始化 UI Provider，使用 WidgetsBinding.instance.addPostFrameCallback 或 Future.microtask 延后到首帧之后
- 避免在 initState/build 内直接调用会触发 state 变更的 Notifier 方法，或对 StateProvider 赋值

示例：

```dart
// 错误：initState 中直接写 provider
@override
void initState() {
  super.initState();
  ref.read(pluginEditorUIProvider.notifier).setUseNativePlayer(...);
}

// 正确：延后到首帧渲染之后
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    ref.read(pluginEditorUIProvider.notifier).setUseNativePlayer(...);
  });
}

// 更好的方式：把初始化放到 Notifier.build()（例如设置页）
class PlayerSettingsNotifier extends Notifier<PlayerSettingsState> {
  @override
  PlayerSettingsState build() {
    final setting = GStorage.setting;
    return PlayerSettingsState(
      defaultPlaySpeed: (setting.get(SettingBoxKey.defaultPlaySpeed, defaultValue: 1.0) as num).toDouble(),
      // ... 其余字段
    );
  }
}
```

---

## 🎉 总结

本次迁移成功将 Kazumi 项目更新到 Riverpod 3.x 最佳实践：

1. ✅ 删除了废弃的 `ChangeNotifier` 实现
2. ✅ 将 `StateNotifierProvider` 迁移到 `NotifierProvider`
3. ✅ 保留了适合使用 `StateProvider` 的简单 UI 状态
4. ✅ 所有代码编译通过，无错误

项目现在完全符合 Riverpod 官方推荐的架构模式！🎊

---

**迁移完成时间**: 2025-11-02
**代码健康度**: 🟢 **优秀**
**Riverpod 版本兼容性**: ✅ **3.x 最佳实践**
