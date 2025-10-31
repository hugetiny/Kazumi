# Riverpod 异步重构指南

## 🎯 目标

将所有远程请求操作从命令式异步处理（manual `.then()`, `setState()`）迁移到声明式 Riverpod 异步模式（`AsyncNotifier`, `FutureProvider`），以解决以下问题：

- ✅ **已修复**: "Future already completed" 错误
- ✅ **已实现**: 自动加载/错误状态管理
- ✅ **已实现**: 防止竞态条件
- ⏳ **待实现**: 请求去重和缓存
- ⏳ **待实现**: 自动取消token支持

## 📋 已完成重构

### 1. ✅ Episode Comments (评论加载)

**文件**: `lib/pages/video/providers.dart`, `lib/pages/player/episode_comments_sheet.dart`

**重构前问题**:

```dart
// ❌ 旧模式：命令式异步 + 手动状态管理
Future<void> loadComments(int episode) async {
  commentsQueryTimeout = false;
  await videoPageController
      .queryBangumiEpisodeCommentsByID(bangumiId, episode)
      .then((_) {
    if (videoPageController.episodeCommentsList.isEmpty && mounted) {
      setState(() { commentsQueryTimeout = true; });
    }
  });
  if (mounted) { setState(() {}); }
}
```

**重构后方案**:

```dart
// ✅ 新模式：AsyncNotifier + 自动状态管理
class EpisodeCommentsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<EpisodeCommentItem>, (int, int)> {
  @override
  Future<List<EpisodeCommentItem>> build((int, int) arg) async {
    final (bangumiId, episode) = arg;
    final episodeInfo = await BangumiHTTP.getBangumiEpisodeByID(bangumiId, episode);
    final result = await BangumiHTTP.getBangumiCommentsByEpisodeID(episodeInfo.id);
    return result.commentList;
  }
}
```

**UI消费**:

```dart
// 自动处理 loading/error/data 三种状态
final commentsAsync = ref.watch(episodeCommentsProvider((bangumiId, episode)));
commentsAsync.when(
  data: (comments) => _buildCommentsList(comments),
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
);
```

**优势**:

- ✅ 自动处理 AsyncValue 状态（loading/data/error）
- ✅ 使用 `ref.invalidate()` 轻松刷新
- ✅ `autoDispose` 自动清理
- ✅ `family` 支持参数化
- ✅ 无竞态条件，一个 Future 生命周期由 Riverpod 管理

---

## 🔄 待重构列表

### 2. ⏳ Info Page Data Loading (番剧详情加载)

**文件**: `lib/pages/info/info_controller.dart`

**当前问题**:

```dart
// ❌ 多个手动异步方法
Future<void> queryBangumiInfo(int id) async { ... }
Future<void> queryBangumiCommentsByID(int id, {int offset = 0}) async { ... }
Future<void> queryBangumiCharactersByID(int id) async { ... }
Future<void> queryBangumiStaffsByID(int id) async { ... }
```

**建议重构**:

创建多个 `AsyncNotifierProvider`:

```dart
// Bangumi 基础信息
final bangumiInfoProvider = AsyncNotifierProvider.autoDispose
    .family<BangumiInfoNotifier, BangumiItem, int>(...);

// Bangumi 评论列表（支持分页）
final bangumiCommentsProvider = AsyncNotifierProvider.autoDispose
    .family<BangumiCommentsNotifier, List<CommentItem>, (int id, int offset)>(...);

// Bangumi 角色列表
final bangumiCharactersProvider = AsyncNotifierProvider.autoDispose
    .family<BangumiCharactersNotifier, List<Character>, int>(...);

// Bangumi Staff列表
final bangumiStaffsProvider = AsyncNotifierProvider.autoDispose
    .family<BangumiStaffsNotifier, List<Staff>, int>(...);
```

---

### 3. ⏳ Timeline/Calendar Loading (时间线加载)

**文件**: `lib/pages/timeline/timeline_controller.dart`

**当前问题**:

```dart
// ❌ 手动管理日历数据
Future<void> initCalendar() async {
  final res = await BangumiHTTP.getCalendar();
  state = state.copyWith(calendarTimeline: res);
}
```

**建议重构**:

```dart
// 完整日历数据
final calendarProvider = AsyncNotifierProvider<CalendarNotifier, List<CalendarItem>>(...);

// 搜索结果
final calendarSearchProvider = AsyncNotifierProvider.autoDispose
    .family<CalendarSearchNotifier, List<CalendarItem>, String>(...);
```

---

### 4. ⏳ Character Page Loading (角色页面加载)

**文件**: `lib/pages/info/character_page.dart`

**当前问题**:

```dart
// ❌ StatefulWidget + manual async
@override
void initState() {
  super.initState();
  BangumiHTTP.getCharacterByCharacterID(widget.characterID).then((value) {
    setState(() { characterItem = value; });
  });
}
```

**建议重构**:

```dart
final characterInfoProvider = AsyncNotifierProvider.autoDispose
    .family<CharacterInfoNotifier, CharacterItem, int>(...);

final characterCommentsProvider = AsyncNotifierProvider.autoDispose
    .family<CharacterCommentsNotifier, List<CommentItem>, int>(...);
```

---

### 5. ⏳ Popular/Trends List (热门列表加载)

**文件**: `lib/pages/popular/popular_controller.dart`

**当前问题**:

```dart
// ❌ 手动分页加载
Future<void> onLoadMore() async {
  final result = await BangumiHTTP.getBangumiTrendsList(offset: trendList.length);
  addTrendList(result.list);
}
```

**建议重构**:

```dart
// 使用 AsyncNotifier 处理分页
class TrendsListNotifier extends AutoDisposeAsyncNotifier<List<BangumiItem>> {
  int offset = 0;

  @override
  Future<List<BangumiItem>> build() async {
    final result = await BangumiHTTP.getBangumiTrendsList(offset: 0);
    offset = result.list.length;
    return result.list;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await BangumiHTTP.getBangumiTrendsList(offset: offset);
      offset += result.list.length;
      return [...current, ...result.list];
    });
  }
}
```

---

### 6. ⏳ Search Page (搜索页面)

**文件**: `lib/pages/search/search_controller.dart`

**当前问题**:

```dart
// ❌ 直接在 controller 中调用
final BangumiItem? item = await BangumiHTTP.getBangumiInfoByID(id);
```

**建议重构**:

直接使用 `bangumiInfoProvider` 即可（参考 #2）

---

## 🎯 重构优先级

1. **高优先级** (已完成):
   - ✅ Episode Comments (已修复生产崩溃)

2. **中优先级** (建议下一步):
   - ⏳ Info Page Data Loading (多个异步操作，容易出错)
   - ⏳ Character Page Loading (简单，适合练手)

3. **低优先级** (可延后):
   - ⏳ Timeline Loading (相对稳定)
   - ⏳ Popular/Trends List (分页逻辑较复杂)
   - ⏳ Search (复用其他 provider)

---

## 📖 Riverpod AsyncNotifier 模式速查

### 基本结构

```dart
class MyAsyncNotifier extends AutoDisposeFamilyAsyncNotifier<DataType, ParamType> {
  @override
  Future<DataType> build(ParamType arg) async {
    // 初始化加载逻辑
    return await fetchData(arg);
  }

  // 可选：手动刷新方法
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final myProvider = AsyncNotifierProvider.autoDispose
    .family<MyAsyncNotifier, DataType, ParamType>(MyAsyncNotifier.new);
```

### UI消费

```dart
final dataAsync = ref.watch(myProvider(param));

// 方式1: when
dataAsync.when(
  data: (data) => DataWidget(data),
  loading: () => LoadingWidget(),
  error: (err, stack) => ErrorWidget(err),
);

// 方式2: map
dataAsync.map(
  data: (data) => DataWidget(data.value),
  loading: (_) => LoadingWidget(),
  error: (err) => ErrorWidget(err.error),
);

// 方式3: 手动判断
if (dataAsync.isLoading) return LoadingWidget();
if (dataAsync.hasError) return ErrorWidget(dataAsync.error);
if (dataAsync.hasValue) return DataWidget(dataAsync.value!);
```

### 刷新数据

```dart
// 方式1: 完全重建
ref.invalidate(myProvider(param));

// 方式2: 手动刷新
ref.read(myProvider(param).notifier).refresh();
```

---

## 🚀 性能优化建议

### 1. 缓存策略

```dart
// 使用 keepAlive 保持数据
class MyNotifier extends FamilyAsyncNotifier<Data, Param> {
  @override
  Future<Data> build(Param arg) async {
    // 保持数据直到手动处理
    final link = ref.keepAlive();

    // 10分钟后自动释放
    Timer(const Duration(minutes: 10), link.close);

    return await fetchData(arg);
  }
}
```

### 2. 请求去重

```dart
// Riverpod 自动去重：相同参数的 provider 只会创建一次
// 多个 widget watch 同一个 provider 不会重复请求
final data1 = ref.watch(myProvider(123));
final data2 = ref.watch(myProvider(123)); // ✅ 复用相同实例
```

### 3. 取消token支持

```dart
class MyNotifier extends AutoDisposeFamilyAsyncNotifier<Data, Param> {
  CancelToken? _cancelToken;

  @override
  Future<Data> build(Param arg) async {
    _cancelToken = CancelToken();

    // 监听 dispose
    ref.onDispose(() {
      _cancelToken?.cancel();
    });

    return await dio.get(
      '/api/data',
      cancelToken: _cancelToken,
    );
  }
}
```

---

## ✅ 重构检查清单

对于每个需要重构的异步操作：

- [ ] 识别数据类型和参数
- [ ] 创建 `AsyncNotifier` 类
- [ ] 将异步逻辑从 controller 移至 `build()` 方法
- [ ] 添加错误处理和日志
- [ ] 创建对应的 provider
- [ ] 更新 UI 使用 `.when()` 或 `.map()`
- [ ] 删除旧的 controller 方法和手动状态管理
- [ ] 删除无用的 `setState()` 调用
- [ ] 测试 loading/error/data 三种状态
- [ ] 测试刷新功能

---

## 📚 参考资源

- [Riverpod AsyncNotifier 官方文档](https://riverpod.dev/docs/concepts/async_notifier_provider)
- [Riverpod 最佳实践](https://riverpod.dev/docs/concepts/best_practices)
- [Riverpod 错误处理](https://riverpod.dev/docs/concepts/error_handling)

---

## 🎓 经验总结

### ✅ 优势

1. **声明式 UI**: 状态自动流向 UI，无需手动 `setState()`
2. **竞态安全**: Riverpod 管理 Future 生命周期，避免 "Future already completed"
3. **自动清理**: `autoDispose` 在 widget 卸载时自动释放资源
4. **类型安全**: `AsyncValue<T>` 提供完整类型推断
5. **测试友好**: provider 易于 mock 和测试

### ⚠️ 注意事项

1. **避免在 build 中调用异步**: 应该 watch provider 而不是直接调用异步方法
2. **正确处理 loading 状态**: 使用 `.when()` 确保覆盖所有状态
3. **合理使用 family**: 过多参数会导致缓存失效
4. **注意 autoDispose 时机**: 需要长期缓存的数据不要使用 `autoDispose`
5. **刷新时保留旧数据**: 可以使用 `state.whenData((old) => ...new)` 模式

---

**最后更新**: 2025-02-14
**状态**: Episode Comments 重构已完成 ✅
**下一步**: Info Page Data Loading 重构 ⏳
