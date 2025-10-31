# Localization Research Log

## Hardcoded String Inventory (2025-10-30)

The following modules still host hardcoded UI strings that must migrate to `lib/l10n/app_*.i18n.json`:

- **Navigation Shell** (`lib/pages/menu/menu.dart`, `lib/router.dart`): tab labels, navigation rail text, search/history tooltips, license dialog metadata.
- **Global Dialogs** (`lib/pages/init_page.dart`, `lib/utils/tray_localization.dart`, `lib/app_widget.dart`): disclaimer, update mirror prompt, toast messages, tray tooltips.
- **Discovery Modules** (`lib/pages/popular/popular_page.dart`, `lib/pages/timeline/timeline_page.dart`): trend/tag titles, action buttons, error states, retry prompts.
- **Library & History** (`lib/pages/my/my_page.dart`, `lib/pages/my/favorites_page.dart`, `lib/pages/history/history_page.dart`): section titles, settings descriptions, confirmation dialogs, empty-state copy.
- **Playback & Player Overlays** (`lib/pages/video/video_page.dart`, `lib/pages/player/player_item.dart`, `lib/pages/player/player_item_panel.dart`, `lib/pages/player/episode_comments_sheet.dart`): toolbar actions, danmaku prompts, error toasts, debug console toggles.
- **WebDAV & Plugin Configuration** (`lib/pages/webdav_editor/webdav_editor_page.dart`, `lib/pages/webdav_editor/webdav_setting.dart`, `lib/pages/plugin_editor/*`): sync prompts, validation messages, call-to-action buttons.
- **Utilities & Miscellaneous** (`lib/utils/logger.dart`, `lib/utils/storage.dart`, scattered `KazumiDialog.showToast` usage) where literal strings appear during plugin updates or sync flows.

This inventory will guide phased migration in alignment with `tasks.md`.
