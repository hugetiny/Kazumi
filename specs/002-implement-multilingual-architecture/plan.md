# Implementation Plan: Full UI Internationalization

**Branch**: `002-full-ui-i18n` | **Date**: 2025-02-14 | **Spec**: [specs/002-implement-multilingual-architecture/spec.md](specs/002-implement-multilingual-architecture/spec.md)

**Input**: Feature specification from `specs/002-implement-multilingual-architecture/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Deliver complete localization coverage for every user-facing surface (desktop tray, navigation, detail flows, error states) while hardening tooling so future UI additions ship with translations by default. We will inventory string usage, migrate hardcoded literals to Slang keys, regenerate translation artifacts, and add automated/tests plus doc updates that enforce ongoing coverage.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart 3.5 via Flutter 3.35.6 (FVM locked)
**Primary Dependencies**: Flutter framework, Riverpod, Slang localization toolkit, Hive (`GStorage` wrapper), tray_manager, media-kit, Dio via `Request`
**Storage**: Hive boxes (`GStorage.setting`, histories, collectibles) with WebDAV sync mirrors
**Testing**: `flutter test`, golden/widget tests where appropriate, custom lint or analyzer rules, existing unit suites under `test/unit`
**Target Platform**: Windows desktop, Android mobile (must retain parity); macOS/Linux builds should not regress
**Project Type**: Cross-platform Flutter application
**Performance Goals**: Maintain <=2 minute localization build step; no runtime regressions in startup or navigation responsiveness
**Constraints**: No new telemetry; must respect Hive retention; translations must load without increasing startup time beyond baseline (monitor via debug logs)
**Scale/Scope**: App spans ~4 primary tabs, dozens of detail screens, player overlays, and tray/desktop dialogs; expect ~200-300 string touchpoints

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Privacy-First Client**: Localization work reads/writes only `GStorage.setting` existing fields; no new storage or retention changes; document locale workflow in `docs/i18n.md`.
- [x] **II. Plugin Safety & Compatibility**: UI translations do not alter plugin selectors. Any plugin-exposed labels remain user-generated content; confirm no networking changes and keep usage routed through existing `Request` helpers.
- [x] **III. Playback Integrity**: Player overlays receive translation reviews; plan manual smoke tests on Windows + Android to ensure localized labels do not break control layouts, danmaku toggles, or shader switches.
- [x] **IV. Cross-Platform Confidence**: Enumerate desktop tray, mobile overlays, and guard platform-specific strings via `KazumiPlatform.isDesktop`. Verify builds on Windows and Android remain unaffected.
- [x] **V. Specification-Driven Delivery**: Spec and plan files in `specs/002-implement-multilingual-architecture/`; tasks will follow via `/speckit.tasks`. Pre-merge commands: `flutter pub run build_runner build --delete-conflicting-outputs`, `flutter test`, localization lint/scan.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
lib/
├── app_widget.dart
├── router.dart
├── pages/
│   ├── popular/
│   ├── timeline/
│   ├── collect/
│   ├── my/
│   ├── settings/
│   ├── player/
│   └── video/
├── modules/
├── providers/
├── utils/
│   ├── tray_localization.dart
│   └── platform.dart
└── l10n/
  └── translations.g.dart

assets/
└── translations/

test/
├── unit/
│   ├── tray_localization_test.dart
│   └── metadata_settings_provider_test.dart
├── widget/
└── integration/

docs/
└── i18n.md
```

**Structure Decision**: Single Flutter application; localization touches shared UI modules under `lib/pages/**`, utilities under `lib/utils/**`, translation assets under `assets/translations`, and verification lives in `test/unit` + `test/widget`. Documentation updates remain in `docs/i18n.md`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| *None* | *N/A* | *N/A* |
