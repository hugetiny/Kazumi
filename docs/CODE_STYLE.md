# Kazumi 代码风格与一致性约定

本项目遵循 Flutter 官方推荐规则（`flutter_lints`），并在此基础上统一如下风格与实践，确保代码可读、可维护、可演进。

## 通用
- 统一使用 `dart format` 自动格式化；提交前建议格式化全仓库。
- 控制流统一加大括号：`if/for/while` 等均使用 `{}` 包裹，即使只有一条语句（已由 `curly_braces_in_flow_control_structures` 强制）。
- 导入顺序遵循 `directives_ordering`：
  1) `dart:` 标准库
  2) 第三方 `package:`
  3) 本地相对导入
  分组之间空一行。
- 尽可能使用 `const` 构造与常量小部件，提高构建性能与可读性。
- 错误与提示：
  - 用户可见提示统一通过 `KazumiDialog.showToast`。
  - 诊断日志统一使用 `KazumiLogger`，包含模块前缀与关键上下文参数。

## 状态管理（Riverpod）
- Provider 类型：
  - 业务状态使用 `Notifier` / `AsyncNotifier`（Riverpod 3.x 推荐），不再使用 `StateNotifier`/`ChangeNotifier`。
  - 页面/短生命周期状态使用 `autoDispose`，全局/跨页面状态避免 `autoDispose`。
- 命名约定：
  - 控制器类：`FooController` / `FooAsyncController`（或根据模块语义命名），状态类：`FooState`。
  - Provider 变量：`fooControllerProvider` / `fooStateProvider`，遵循小驼峰+`Provider` 后缀。
- 初始化约定：
  - 首次加载逻辑放在 `build()` 中完成（从 Hive/本地读取、网络预加载等）。
  - 严禁在 Widget 的 `initState/build/dispose` 等生命周期中修改 Provider；如确需联动 UI 初始化，使用 `postFrameCallback` 并仅限 UI 层状态。
- 事件更新：
  - 通过 `ref.read(provider.notifier)` 派发事件，避免在 `build()` 中直接写入状态。

## 路由与 UI
- 路由常量集中在 `router.dart`（或 `Routes` 常量类）统一管理，禁止魔法字符串散落各处。
- Material 主题与 OLED 深色模式通过 `themeNotifierProvider` 管理；遵循模块化主题扩展策略。
- 新页面应：
  - 将数据与副作用放在 Controller 中；
  - UI 仅订阅状态与触发事件；
  - 避免在 `build()` 里执行耗时与副作用。

## 插件与爬虫
- 插件模型位于 `lib/plugins`，遵循现有 `Plugin` 定义与兼容策略；
- 网络请求遵循 `Request` + `ApiInterceptor` 统一出入口，必要时设置 `extra['customError']` 与 `shouldRethrow: true` 控制错误呈现与传播。

## 存储与同步
- 持久化统一经 `GStorage`（Hive），key 常量集中定义；
- WebDAV 同步遵循 `lib/utils/webdav.dart` 里的合并/调度策略，注意 `isHistorySyncing` 互斥标记。

## 提交流程建议
- 本地执行：
  - `dart format .`
  - `flutter analyze`
  - `flutter test`
- 若引入/变更了 `freezed`/`json_serializable` 等生成模型，执行：
  - `flutter pub run build_runner build --delete-conflicting-outputs`

如遇违反约定的情形，请在 PR 中说明原因与权衡，并附上回归测试或验证步骤。
