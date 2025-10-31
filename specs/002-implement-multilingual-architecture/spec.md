# Feature Specification: Full UI Internationalization

**Feature Branch**: `[002-full-ui-i18n]`
**Created**: 2025-02-14
**Status**: Draft
**Input**: User description: "现在整个app还有很多地方没有国际化…请完整翻译"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - All core navigation strings localized (Priority: P1)

As a bilingual user switching the app to a supported locale, I see every top-level navigation element (tabs, drawers, dialogs, tray menu, update prompts) rendered in my chosen language so I can move through the app without reading untranslated text.

**Why this priority**: Navigation labels, global dialogs, and tray actions are the main interaction points. Missing translations here blocks users from even discovering features.

**Independent Test**: Configure the app in each supported locale (currently Simplified Chinese and English), traverse the `/tab/popular`, `/tab/timeline`, `/tab/collect`, `/tab/my` routes, open dialogs (search, settings, update, error toast, tray menu), and confirm zero fallback English strings remain.

**Acceptance Scenarios**:

1. **Given** the app is set to English, **When** I open the tab bar and primary dialogs, **Then** every label displays in English with no Chinese fallbacks.
2. **Given** the app is set to Simplified Chinese, **When** I open the system tray menu, **Then** all menu entries and tooltips appear in Simplified Chinese with no English leftovers.

---

### User Story 2 - Secondary modules and detail views localized (Priority: P2)

As a user browsing anime details, episodes, comments, download panels, and account screens, I see descriptive labels, button text, and status messages in my active locale so I can interact with content-heavy screens comfortably.

**Why this priority**: While users can navigate, missing translations inside detail views causes confusion during core workflows like playback, syncing, or managing collections.

**Independent Test**: Enter each module (popular detail, timeline detail, player overlays, history, collection management, WebDAV sync, download/tasks). For each locale, trigger empty states, loading indicators, errors, and confirm all visible text uses translation keys.

**Acceptance Scenarios**:

1. **Given** the locale is English, **When** I open an anime detail page and scroll through sections (synopsis, episodes, comments, related), **Then** every header, action button, and status message is localized.
2. **Given** WebDAV sync fails while the locale is Simplified Chinese, **When** the error toast appears, **Then** the toast text and retry action are localized in Simplified Chinese.

---

### User Story 3 - Continuous translation coverage tooling (Priority: P3)

As a maintainer adding new UI text, I receive clear guidance and automated checks that enforce providing translations so future features remain localized without manual audits.

**Why this priority**: Ensures sustainability—without tooling and guidelines, translation drift will reappear after this push.

**Independent Test**: Review CI/test output and developer documentation. A new untranslated string should trigger either a failing test/analysis step or a documented checklist that developers follow before merge.

**Acceptance Scenarios**:

1. **Given** a developer introduces a new `Text('Hello')` string, **When** tests or linting run, **Then** the suite fails or warning appears instructing them to add a translation key.
2. **Given** a maintainer updates translation files, **When** they read `docs/i18n.md`, **Then** they find updated guidance describing translation workflow and verification steps.

---

### Edge Cases

- Missing translation key: fallback must gracefully display default language and log a warning so maintainers can patch quickly.
- Locale file corrupted or user selects unsupported locale: app should revert to default (follow system or Simplified Chinese) without crashing.
- External plugin labels or scraped text cannot be localized server-side: UI must clearly delineate user-generated content vs. shell UI, avoiding misleading localization attempts.
- Desktop vs. mobile: ensure platform-exclusive dialogs (tray, desktop window controls) and mobile-specific banners are translated or hidden appropriately.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All user-facing strings MUST reference Slang translation keys; direct hardcoded literals are prohibited unless clearly marked as user-generated content.
- **FR-002**: Locale selection MUST persist through `GStorage.setting` and respect follow-system behaviour without requiring app restart.
- **FR-003**: Localization MUST cover desktop-only surfaces (tray menu, window chrome prompts) and mobile-only overlays, gated by platform checks to satisfy cross-platform confidence.
- **FR-004**: Build pipeline MUST regenerate translation artifacts via `flutter pub run build_runner build --delete-conflicting-outputs` or `slang` commands, and `flutter test` MUST include coverage for locale regressions.
- **FR-005**: Documentation MUST outline translation workflow, including how to add keys, regenerate artifacts, and validate coverage locally and in CI.
- **FR-006**: QA checklist MUST enumerate manual verification of English and Simplified Chinese on Windows and Android for navigation, detail views, playback controls, and error states.

### Key Entities *(include if feature involves data)*

- **Translation Key Catalog**: Logical grouping of localization keys (navigation, dialogs, errors, settings) mapped to Slang JSON resources.
- **LocaleSettingsState**: Persisted Riverpod state representing active locale, follow-system flag, and last manual override timestamp for audit/logging.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero untranslated string regressions detected by automated scan (e.g., custom lint or snapshot test) across supported locales in CI.
- **SC-002**: Manual QA confirms 100% coverage for primary flows (navigation, detail, playback, settings) in both supported locales on Windows and Android before release.
- **SC-003**: Documentation updates reduce follow-up localization support tickets by at least 50% in the subsequent release cycle (tracked via internal issue labels).
- **SC-004**: Translation build pipeline completes under 2 minutes on developer machines, ensuring localization workflow remains lightweight.
