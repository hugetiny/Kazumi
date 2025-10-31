# Provider 迁移指南

## 📚 StateProvider 迁移到 Notifier

### Info 页面 UI State

#### 之前 (使用 StateProvider)
```dart
// 读取状态
final fullIntro = ref.watch(fullIntroProvider);

// 修改状态
ref.read(fullIntroProvider.notifier).state = !fullIntro;
```

#### 之后 (使用 InfoUINotifier)
```dart
// 读取状态
final uiState = ref.watch(infoUIProvider);
final fullIntro = uiState.fullIntro;

// 或者直接选择特定字段
final fullIntro = ref.watch(infoUIProvider.select((s) => s.fullIntro));

// 修改状态
ref.read(infoUIProvider.notifier).toggleFullIntro();
// 或
ref.read(infoUIProvider.notifier).setFullIntro(true);
```

#### 完整示例
```dart
// 在 info_tabview.dart 中

// ❌ 旧代码
Widget build(BuildContext context, WidgetRef ref) {
  final fullIntro = ref.watch(fullIntroProvider);

  return GestureDetector(
    onTap: () {
      ref.read(fullIntroProvider.notifier).state = !fullIntro;
    },
    child: Text(fullIntro ? '收起' : '展开'),
  );
}

// ✅ 新代码
Widget build(BuildContext context, WidgetRef ref) {
  final fullIntro = ref.watch(infoUIProvider.select((s) => s.fullIntro));

  return GestureDetector(
    onTap: () {
      ref.read(infoUIProvider.notifier).toggleFullIntro();
    },
    child: Text(fullIntro ? '收起' : '展开'),
  );
}
```

---

### Plugin Editor UI State

#### 之前
```dart
final usePost = ref.watch(pluginEditorUsePostProvider);
ref.read(pluginEditorUsePostProvider.notifier).state = true;
```

#### 之后
```dart
final usePost = ref.watch(pluginEditorUIProvider.select((s) => s.usePost));
ref.read(pluginEditorUIProvider.notifier).setUsePost(true);
```

---

### Plugin Shop UI State

#### 之前
```dart
final isLoading = ref.watch(pluginShopLoadingProvider);
ref.read(pluginShopLoadingProvider.notifier).state = true;
```

#### 之后
```dart
final isLoading = ref.watch(pluginShopUIProvider.select((s) => s.isLoading));
ref.read(pluginShopUIProvider.notifier).setLoading(true);
```

---

### Plugin Selection State

#### 之前
```dart
final multiSelectMode = ref.watch(pluginMultiSelectModeProvider);
final selectedNames = ref.watch(pluginSelectedNamesProvider);

// 开启多选
ref.read(pluginMultiSelectModeProvider.notifier).state = true;

// 修改选中项
final newSet = Set<String>.from(ref.read(pluginSelectedNamesProvider));
newSet.add('plugin_name');
ref.read(pluginSelectedNamesProvider.notifier).state = newSet;
```

#### 之后
```dart
final selectionState = ref.watch(pluginSelectionProvider);
final multiSelectMode = selectionState.multiSelectMode;
final selectedNames = selectionState.selectedNames;

// 或使用 select
final multiSelectMode = ref.watch(
  pluginSelectionProvider.select((s) => s.multiSelectMode)
);

// 开启多选
ref.read(pluginSelectionProvider.notifier).enableMultiSelect();

// 切换选中状态
ref.read(pluginSelectionProvider.notifier).toggleSelection('plugin_name');

// 全选
ref.read(pluginSelectionProvider.notifier).selectAll(pluginNames);

// 清空选择
ref.read(pluginSelectionProvider.notifier).clearSelection();
```

---

## 🔄 需要手动修改的文件

### 1. `lib/pages/info/info_tabview.dart`

需要修改 6 处:

```dart
// Line 86 - 读取 fullIntro
// ❌ final fullIntro = ref.watch(fullIntroProvider);
// ✅ final fullIntro = ref.watch(infoUIProvider.select((s) => s.fullIntro));

// Line 114 - 切换 fullIntro
// ❌ ref.read(fullIntroProvider.notifier).state = !fullIntro;
// ✅ ref.read(infoUIProvider.notifier).toggleFullIntro();

// Line 135 - 读取 fullTag
// ❌ final fullTag = ref.watch(fullTagProvider);
// ✅ final fullTag = ref.watch(infoUIProvider.select((s) => s.fullTag));

// Line 154 - 切换 fullTag
// ❌ ref.read(fullTagProvider.notifier).state = !fullTag;
// ✅ ref.read(infoUIProvider.notifier).toggleFullTag();

// Line 290 - 读取 showAllEpisodes
// ❌ final showAllEpisodes = ref.watch(showAllEpisodesProvider);
// ✅ final showAllEpisodes = ref.watch(infoUIProvider.select((s) => s.showAllEpisodes));

// Line 311 - 切换 showAllEpisodes
// ❌ ref.read(showAllEpisodesProvider.notifier).state = !showAllEpisodes;
// ✅ ref.read(infoUIProvider.notifier).toggleShowAllEpisodes();
```

### 2. `lib/pages/plugin_editor/plugin_editor_page.dart`

需要修改多处 (估计 6-8 处):

```dart
// 读取状态
// ❌ final useNativePlayer = ref.watch(pluginEditorUseNativePlayerProvider);
// ✅ final useNativePlayer = ref.watch(pluginEditorUIProvider.select((s) => s.useNativePlayer));

// ❌ final usePost = ref.watch(pluginEditorUsePostProvider);
// ✅ final usePost = ref.watch(pluginEditorUIProvider.select((s) => s.usePost));

// ❌ final useLegacyParser = ref.watch(pluginEditorUseLegacyParserProvider);
// ✅ final useLegacyParser = ref.watch(pluginEditorUIProvider.select((s) => s.useLegacyParser));

// 修改状态
// ❌ ref.read(pluginEditorUsePostProvider.notifier).state = value;
// ✅ ref.read(pluginEditorUIProvider.notifier).setUsePost(value);

// ❌ ref.read(pluginEditorUseLegacyParserProvider.notifier).state = value;
// ✅ ref.read(pluginEditorUIProvider.notifier).setUseLegacyParser(value);

// ❌ ref.read(pluginEditorUseNativePlayerProvider.notifier).state = value;
// ✅ ref.read(pluginEditorUIProvider.notifier).setUseNativePlayer(value);
```

### 3. `lib/pages/plugin_editor/plugin_shop_page.dart` (如果有使用)

```dart
// ❌ ref.read(pluginShopLoadingProvider.notifier).state = true;
// ✅ ref.read(pluginShopUIProvider.notifier).setLoading(true);

// ❌ ref.read(pluginShopTimeoutProvider.notifier).state = true;
// ✅ ref.read(pluginShopUIProvider.notifier).setTimeout(true);

// ❌ ref.read(pluginShopSortByNameProvider.notifier).state = true;
// ✅ ref.read(pluginShopUIProvider.notifier).setSortByName(true);
```

### 4. `lib/pages/plugin_editor/plugin_view_page.dart` (如果有使用)

```dart
// 多选模式
// ❌ ref.read(pluginMultiSelectModeProvider.notifier).state = true;
// ✅ ref.read(pluginSelectionProvider.notifier).enableMultiSelect();

// 退出多选
// ❌ ref.read(pluginMultiSelectModeProvider.notifier).state = false;
// ❌ ref.read(pluginSelectedNamesProvider.notifier).state = {};
// ✅ ref.read(pluginSelectionProvider.notifier).disableMultiSelect();

// 切换选中
// ❌ 需要手动管理 Set
// ✅ ref.read(pluginSelectionProvider.notifier).toggleSelection(pluginName);
```

---

## ✅ 迁移检查清单

- [ ] `lib/pages/info/info_tabview.dart` - fullIntro, fullTag, showAllEpisodes (6处)
- [ ] `lib/pages/plugin_editor/plugin_editor_page.dart` - usePost, useLegacyParser, useNativePlayer
- [ ] `lib/pages/plugin_editor/plugin_shop_page.dart` - isLoading, isTimeout, sortByName (如果有)
- [ ] `lib/pages/plugin_editor/plugin_view_page.dart` - multiSelectMode, selectedNames (如果有)

---

## 🎯 迁移优势

### 1. 类型安全
```dart
// ❌ StateProvider - 容易出错
ref.read(fullIntroProvider.notifier).state = "wrong type"; // 编译时可能不报错

// ✅ Notifier - 类型安全
ref.read(infoUIProvider.notifier).setFullIntro("wrong type"); // 编译错误
```

### 2. 更好的封装
```dart
// ❌ StateProvider - 直接暴露状态
.state = value  // 任何人都可以随意修改

// ✅ Notifier - 通过方法控制
.toggleFullIntro()  // 明确的意图，更易于维护
```

### 3. 相关状态集中管理
```dart
// ❌ 3个零散的 provider
final fullIntro = ref.watch(fullIntroProvider);
final fullTag = ref.watch(fullTagProvider);
final showAllEpisodes = ref.watch(showAllEpisodesProvider);

// ✅ 1个统一的 state
final uiState = ref.watch(infoUIProvider);
// 所有相关状态一目了然
```

---

## 📝 快速替换脚本

你可以使用以下正则表达式进行查找替换:

### Info TabView
```
查找: ref\.watch\(fullIntroProvider\)
替换: ref.watch(infoUIProvider.select((s) => s.fullIntro))

查找: ref\.read\(fullIntroProvider\.notifier\)\.state = !fullIntro
替换: ref.read(infoUIProvider.notifier).toggleFullIntro()

// 类似地替换 fullTagProvider 和 showAllEpisodesProvider
```

---

## 🚀 完成后

运行以下命令确保没有编译错误:

```bash
flutter analyze
flutter test
```

如果一切正常，恭喜你完成了 Riverpod 架构的现代化！🎉
