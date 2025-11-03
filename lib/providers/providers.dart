// 统一导出所有 Riverpod Providers
// 按功能分类组织，方便统一导入
// 说明：部分页面级 Provider 使用 autoDispose（如 video、info、search），
// 在页面销毁时会自动清理状态以降低内存占用。
//
// 使用方式:
// ```dart
// import 'package:kazumi/providers/providers.dart';
//
// // 直接访问所有 Provider
// ref.read(popularProvider.notifier);
// ref.watch(videoProvider);
// ```

// ==================== 核心功能 Providers ====================
export 'package:kazumi/pages/popular/providers.dart'; // popularProvider
export 'package:kazumi/pages/timeline/providers.dart'; // timelineProvider
export 'package:kazumi/pages/my/providers.dart'; // collectionsProvider, favoritesShowDeleteProvider, favoritesSyncingProvider
export 'package:kazumi/pages/history/providers.dart'; // historyProvider
export 'package:kazumi/pages/video/providers.dart'; // videoProvider, episodeCommentsProvider, selectedEpisodeProvider, showDebugLogProvider, etc.
export 'package:kazumi/pages/search/providers.dart'; // searchProvider
export 'package:kazumi/pages/info/providers.dart'; // bangumiInfoProvider, bangumiCommentsProvider, bangumiCharactersProvider, bangumiStaffsProvider

// ==================== 设置 Providers ====================
export 'package:kazumi/pages/setting/providers.dart'; // themeProvider, playerSettingsProvider, metadataSettingsProvider, localeSettingsProvider, showWindowButtonProvider
export 'package:kazumi/pages/settings/danmaku/providers.dart'; // danmakuSettingsProvider
export 'package:kazumi/pages/webdav_editor/providers.dart'; // webDavSettingsProvider

// ==================== 插件系统 Providers ====================
export 'package:kazumi/plugins/plugins_providers.dart'; // pluginsProvider, pluginEditorUIProvider, pluginShopUIProvider, pluginSelectionProvider

// ==================== 播放器相关 Providers ====================
export 'package:kazumi/pages/player/player_providers.dart'; // playerProvider
export 'package:kazumi/pages/webview/providers.dart'; // webviewItemControllerProvider

// ==================== 工具和辅助 Providers ====================
export 'package:kazumi/shaders/providers.dart'; // shadersControllerProvider
export 'package:kazumi/providers/media_suite_providers.dart'; // metadataClientProvider, metadataSyncControllerProvider
export 'package:kazumi/providers/translations_provider.dart'; // translationsProvider
