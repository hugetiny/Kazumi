# Implementation Plan: Kazumi Media Experience Suite

**Branch**: `001-media-suite` | **Date**: 2025-10-28 | **Spec**: [spec.md](../001-media-suite/spec.md)
**Input**: Feature specification from `/specs/001-media-suite/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Deliver a unified media experience that harmonizes official metadata from Bangumi/TMDb, stabilizes playback enhancements (Anime4K, danmaku, subtitle auto-match), integrates aria2-backed downloads with library classification, codifies `slang`-driven localization (defaulting to Simplified Chinese), and adds torrent-aware plugin parsing so magnets flow straight into the managed queue while honoring consent and locality constraints.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart 3.x (Flutter stable channel)
**Primary Dependencies**: Flutter, Riverpod, Dio (`Request` wrapper), Hive, media-kit, Anime4K shaders, aria2 RPC (HTTP + BitTorrent magnet support), `xpath_selector_html_parser`, `slang` + `slang_flutter`
**Storage**: Hive boxes via `GStorage` (metadata cache, download state, playback preferences)
**Testing**: `flutter test`, widget/integration tests, manual smoke tests on Windows + Android
**Target Platform**: Windows desktop, Android mobile/tablet, secondary macOS/Linux support
**Project Type**: Cross-platform Flutter application
**Performance Goals**: Maintain 60 fps playback with Anime4K enabled; metadata sync completes <5 min for 500 titles; aria2 queue updates within 2s
**Constraints**: Metadata cache retention ≤24h unless user opts in; playback must gracefully degrade when shaders/danmaku unavailable; aria2 concurrency default 2 tasks with user override; torrent usage requires explicit user consent and tracker traffic must respect regional restrictions; localization strings generated via `slang` with Simplified Chinese shipping as default locale
**Scale/Scope**: Library sizes up to 5k entries; download queue up to 50 tasks; concurrent platform usage Windows + Android

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Privacy-First Client**: Hive boxes affected (metadata cache, download tasks, playback profiles) documented; retention capped at 24h with opt-in overrides; aria2/download settings surfaced in consent flows.
- [x] **II. Plugin Safety & Compatibility**: Metadata and torrent fetches piggyback on existing plugins with `Request` wrapper; plan includes selector validation fixtures, torrent consent gating, and logging strategy.
- [x] **III. Playback Integrity**: Smoke test matrix defined (Windows hw on/off, Android mid/high tier, 30-minute sessions with Anime4K, danmaku, subtitles) per research.md.
- [x] **IV. Cross-Platform Confidence**: Platforms (Windows, Android primary; macOS/Linux secondary) noted with runtime guards for aria2 controls.
- [x] **V. Specification-Driven Delivery**: `/speckit.spec` complete; `/speckit.plan` in progress; `/speckit.tasks` queued; build commands (`flutter analyze`, `flutter test`, build_runner) slated pre-merge.

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
├── modules/
│   ├── metadata_sync/          # New orchestration for Bangumi/TMDb merging
│   ├── downloads/              # aria2 client, queue manager, torrent consent gate
│   └── playback/               # Shared playback enhancements + smoke test hooks
├── l10n/
│   └── translations.g.dart (generated via slang)  # Localization artifacts with Simplified Chinese default
├── pages/
│   ├── library/                # UI for enriched catalog metadata
│   ├── player/                 # Update controls for Anime4K/danmaku/subtitles
│   └── settings/               # Source toggles, download concurrency settings
├── providers/
│   └── ... (register new Riverpod notifiers)
├── utils/
│   └── aria2_client.dart       # RPC helper (if not in modules)
└── request/
    └── metadata_client.dart    # Wrapper customizing `Request` usage

test/
├── integration/
│   ├── metadata_sync_test.dart
│   ├── playback_smoke_test.dart
│   ├── download_queue_test.dart
│   └── torrent_selector_test.dart
└── widget/
    └── library_page_test.dart
```

**Structure Decision**: Extend existing Flutter monorepo layout by adding dedicated modules under `lib/modules/` for metadata sync, downloads, and playback, with corresponding Riverpod providers and UI pages under `lib/pages/`. Tests reside in `test/integration` and `test/widget` to exercise metadata refresh, playback stack, and download queue behaviour.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | — | — |

## Phase 0: Research Objectives

- Confirm playback smoke test coverage across Windows (hardware acceleration on/off) and Android tiers; document scenarios in `research.md`.
- Outline metadata caching/refresh strategy honoring 24-hour retention and locale precedence rules.
- Determine aria2 RPC concurrency configuration and user override UX.
- Document torrent plugin landscape, consent/legal messaging requirements, and aria2 magnet support constraints.
- Inventory existing localization files and plan migration to `slang` including default Simplified Chinese resources.

**Artifacts**: `research.md` (complete)

## Phase 1: Design & Contracts

- Model entities (`MetadataSource`, `LibraryEntry`, `DownloadTask`, `TorrentEntry`, `PlaybackProfile`) inside `data-model.md` (complete).
- Define internal service contracts for metadata, downloads, and playback profile interactions (`contracts/media-suite.openapi.yaml`).
- Draft quickstart instructions covering metadata refresh, playback verification, torrent opt-in, and download queue validation (`quickstart.md`).
- Note `slang` integration steps in `quickstart.md` for generating additional locales and setting Simplified Chinese default.
- Update agent context with new tech stack notes (done via `update-agent-context.ps1`).

Re-run Constitution Check → all gates satisfied.

## Phase 2: Implementation Strategy (Preview)

1. Scaffold new modules under `lib/modules/` and wire Riverpod providers.
2. Implement metadata sync pipeline with locale-aware precedence and Hive cache management.
3. Integrate playback enhancements, ensuring degradations log via `KazumiLogger` across platforms.
4. Build aria2 download controller with configurable concurrency, torrent magnet normalization, consent enforcement, and queue progress polling.
5. Wire `slang` localization flows, ensuring Simplified Chinese default resources and fallback messaging align with consent requirements.
6. Create integration tests covering metadata, playback, downloads, and torrent parsing; supplement with manual smoke tests from the defined matrix.
7. Document release notes highlighting privacy, plugin validation (including torrent consent), localization shifts, and testing outcomes.

`/speckit.tasks` will decompose these steps into executable tasks.
