// 统一导出所有 Riverpod Providers
// 按功能分类组织，方便统一导入

// Feature Providers - 核心功能模块
export 'package:kazumi/pages/popular/providers.dart';        // popularProvider
export 'package:kazumi/pages/timeline/providers.dart';       // timelineProvider
export 'package:kazumi/pages/my/providers.dart';             // collectionsProvider
export 'package:kazumi/pages/history/providers.dart';        // historyProvider
export 'package:kazumi/pages/video/providers.dart';          // videoProvider, episodeCommentsProvider
export 'package:kazumi/pages/search/providers.dart';         // searchProvider
export 'package:kazumi/pages/info/providers.dart';           // bangumiInfoProvider, bangumiCommentsProvider, etc.

// Utility Providers - 工具和辅助功能
export 'package:kazumi/shaders/providers.dart';              // shadersControllerProvider
export 'package:kazumi/providers/media_suite_providers.dart'; // metadataClientProvider, etc.
