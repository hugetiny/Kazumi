# Tasks: Kazumi Media Experience Suite

**Input**: Design documents from `/specs/001-media-suite/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Principle V requires acceptance evidence. Add automated `flutter test` coverage or document the manual playback matrices noted in quickstart.md for each story’s acceptance criteria.

**Organization**: Tasks are grouped by user story so each slice is independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Task can be executed in parallel (different files, no blocking dependencies)
- **[Story]**: Maps task to user story (US1, US2, US3, US4)
- Include concrete file paths in every task description

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish toolchain and scaffolding required by later phases.

- [x] T001 Run `flutter pub get` from project root `.`
- [x] T002 Execute `flutter pub run build_runner build --delete-conflicting-outputs` from `.`
- [x] T003 [P] Configure `slang.yaml` so Simplified Chinese is default and planned locales align with media suite scope
- [x] T004 [P] Update `specs/001-media-suite/quickstart.md` prerequisites to reflect Bangumi/TMDb credential setup and aria2 daemon instructions

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared infrastructure that every user story depends on.

- [x] T005 Extend Hive initialization and retention defaults in `lib/utils/storage.dart` for metadataCache, downloadTasks, torrentEntries, and playbackProfiles boxes
- [x] T006 [P] Centralize upstream credentials in `lib/utils/api_credentials.dart` and expose overrides via `lib/utils/storage.dart`
- [x] T007 [P] Publish shared Riverpod providers in `lib/providers/media_suite_providers.dart` wiring metadata, playback, and download controllers
- [x] T008 [P] Implement aria2 RPC helper with concurrency configuration in `lib/utils/aria2_client.dart`
- [x] T009 [P] Add platform guard utilities for Windows/Android feature flags in `lib/utils/platform_guard.dart`

**Checkpoint**: Foundation complete; user story work may proceed in priority order.

---

## Phase 3: User Story 1 – Discover Official Metadata (Priority: P1) 🎯 MVP

**Goal**: Enrich catalogue entries with Bangumi/TMDb metadata using locale-aware precedence and user toggles.

**Independent Test**: Refresh metadata for a single slug and verify updated title, synopsis, artwork, and episode list in the library view without enabling other stories.

### Tests for User Story 1 (Acceptance Evidence) ⚠️

- [x] T010 [P] [US1] Add integration coverage for metadata refresh in `test/integration/metadata_sync_test.dart`
- [x] T011 [P] [US1] Create cache repository unit tests in `test/unit/metadata_cache_repository_test.dart`

### Implementation for User Story 1

- [x] T012 [US1] Define Hive metadata models in `lib/modules/metadata_sync/models/metadata_record.dart`
- [x] T013 [US1] Implement retention and merge logic in `lib/modules/metadata_sync/metadata_cache_repository.dart`
- [x] T014 [US1] Build metadata sync controller orchestration in `lib/modules/metadata_sync/metadata_sync_controller.dart`
- [x] T015 [US1] Extend locale-aware fetch and fallback logic in `lib/request/metadata_client.dart`
- [x] T016 [US1] Wire metadata providers and adapters in `lib/providers/media_suite_providers.dart` and `lib/utils/storage.dart`
- [x] T017 [US1] Surface metadata source toggles and locale overrides in `lib/pages/setting/setting_page.dart` and `lib/pages/setting/providers.dart`
- [x] T018 [US1] Render enriched metadata within `lib/pages/info/info_controller.dart`, `lib/pages/info/info_page.dart`, and `lib/pages/info/info_tabview.dart`
- [x] T019 [US1] Add structured sync logging via `KazumiLogger` in `lib/modules/metadata_sync/metadata_sync_controller.dart`

**Checkpoint**: User Story 1 is independently functional (MVP).

---

## Phase 4: User Story 2 – Enhanced Playback Immersion (Priority: P2)

**Goal**: Deliver synchronized danmaku, Anime4K filters, and subtitle auto-matching with safe platform fallbacks.

**Independent Test**: Play an episode on Windows and Android, toggling Anime4K, danmaku, and subtitle auto-selection with smooth playback even if metadata sync/download stories are disabled.

### Tests for User Story 2 (Acceptance Evidence) ⚠️

- [ ] T020 [P] [US2] Author playback smoke integration test in `test/integration/playback_smoke_test.dart`
- [x] T021 [P] [US2] Document platform playback checklist updates in `specs/001-media-suite/quickstart.md`

### Implementation for User Story 2

- [ ] T022 [US2] Enhance playback state and controller in `lib/pages/player/player_state.dart` and `lib/pages/player/player_controller.dart`
- [ ] T023 [US2] Update playback UI controls in `lib/pages/player/player_item.dart` and `lib/pages/player/player_providers.dart`
- [x] T024 [US2] Implement subtitle auto-match heuristics in `lib/modules/playback/subtitle_matcher.dart`
- [ ] T025 [US2] Expose danmaku/subtitle toggles in `lib/pages/settings/player_settings.dart` and `lib/pages/settings/providers.dart`
- [ ] T026 [US2] Apply shader and danmaku platform guards in `lib/utils/platform_guard.dart` and `lib/pages/player/player_controller.dart`
- [ ] T027 [US2] Surface DanDan credential overrides in `lib/pages/settings/danmaku/danmaku_settings.dart`, `lib/utils/storage.dart`, and `lib/request/interceptor.dart`

**Checkpoint**: User Stories 1 and 2 operate independently.

---

## Phase 5: User Story 4 – Torrent Source Integration (Priority: P2)

**Goal**: Parse torrent metadata from plugins, enforce consent, and launch magnets through aria2 with resilient error handling.

**Independent Test**: Enable a torrent-capable plugin, inspect torrent details, and start a magnet download that reports progress without manual URI edits while other stories remain disabled.

### Tests for User Story 4 (Acceptance Evidence) ⚠️

- [ ] T028 [P] [US4] Create torrent selector integration test in `test/integration/torrent_selector_test.dart`

### Implementation for User Story 4

- [ ] T029 [US4] Normalize torrent metadata ingestion in `lib/plugins/plugins_controller.dart` and `lib/plugins/plugins_providers.dart`
- [ ] T030 [US4] Implement torrent consent flows in `lib/pages/setting/setting_page.dart` and `lib/providers/media_suite_providers.dart`
- [ ] T031 [US4] Dispatch magnets with session cookies via `lib/utils/aria2_client.dart`
- [ ] T032 [US4] Present torrent options alongside streams in `lib/pages/video/video_page.dart` and `lib/pages/video/video_controller.dart`
- [ ] T033 [US4] Surface aria2 rejection diagnostics in `lib/pages/video/video_controller.dart` and `lib/utils/logger.dart`

**Checkpoint**: Torrent flows function with metadata and playback stories.

---

## Phase 6: User Story 3 – Unified Download & Library Control (Priority: P3)

**Goal**: Queue downloads via aria2, monitor progress, and classify episodes within the library alongside watch history.

**Independent Test**: Queue a download, observe progress, and confirm library classification updates without relying on metadata or playback enhancements.

### Tests for User Story 3 (Acceptance Evidence) ⚠️

- [ ] T034 [P] [US3] Implement download queue integration test in `test/integration/download_queue_test.dart`

### Implementation for User Story 3

- [ ] T035 [US3] Model aria2 download tasks and persistence in `lib/modules/downloads/download_task.dart` and `lib/utils/storage.dart`
- [ ] T036 [US3] Build download queue controller with concurrency slots in `lib/modules/downloads/download_queue_controller.dart`
- [ ] T037 [US3] Present download progress/actions in `lib/pages/my/my_page.dart` and `lib/pages/my/providers.dart`
- [ ] T038 [US3] Sync completed downloads with library entries in `lib/pages/info/info_controller.dart` and `lib/modules/metadata_sync/metadata_cache_repository.dart`
- [ ] T039 [US3] Expose concurrent download limits in `lib/pages/setting/setting_page.dart` and `lib/pages/setting/providers.dart`
- [ ] T040 [US3] Extend WebDAV sync coverage in `lib/utils/webdav.dart` and `lib/utils/storage.dart`

**Checkpoint**: All user stories deliver independently testable increments.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Hardening, documentation, and release readiness across the suite.

- [ ] T041 [P] Update release and privacy notes in `README.md` and `specs/001-media-suite/research.md`
- [ ] T042 Run full verification via `flutter test` and `flutter analyze` from project root `.`
- [ ] T043 Strengthen structured logging and consent audit trails in `lib/utils/logger.dart` and `lib/utils/storage.dart`

---

## Dependencies & Execution Order

- **Phase 1 → Phase 2** → User stories in priority order (US1 P1 → US2 P2 → US4 P2 → US3 P3) → **Polish**
- User stories can begin only after Phase 2 completes; afterwards they may proceed sequentially or in parallel if ownership is clear.
- Within each story, complete tests before implementation tasks to honor acceptance criteria.

## Parallel Execution Examples

- Setup: T003 and T004 can progress while T001–T002 run.
- Foundational: T006–T009 are marked [P]; distribute across owners once Hive updates (T005) land.
- US1: T010 and T011 can execute concurrently; T016–T018 depend on earlier modeling tasks.
- US2: T020 and T021 proceed in parallel; T027 can be isolated once storage overrides from T006 exist.
- US4: T028 unblocks while T029–T033 evolve; UI (T032) waits for ingestion logic (T029).
- US3: T034 may start after T035 scaffolds models; T037 and T039 can run in parallel once controller (T036) is ready.

## Implementation Strategy

1. Complete Phases 1–2 to solidify shared infrastructure.
2. Deliver User Story 1 as the MVP and validate via T010–T019.
3. Layer User Story 2’s playback enhancements while maintaining independence.
4. Implement User Story 4 to unlock torrent ingestion, reusing aria2 foundations.
5. Finish with User Story 3 to unify downloads with the library.
6. Close with Polish tasks to document, verify, and harden the release.
