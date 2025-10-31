# Feature Specification: Kazumi Media Experience Suite

**Feature Branch**: `001-media-suite`
**Created**: 2025-10-28
**Status**: Draft
**Input**: User description: "1.信息采集从bangumi，tmdb等公开api（目前仅实现bangumi）
2.在线视频弹幕播放，包括Animate4k等滤镜加强播放功能，和弹幕功能（目前仅实现类似bilibili弹幕功能）
3.字幕自动下载匹配
4.aria2文件下载管理器
5.视频管理分类(播放历史记录和基于bangumi等api的播放喜好已经实现)"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently

  Constitution alignment:
  - Capture privacy impacts (new storage boxes, retention changes, consent flows).
  - Note plugin validation strategy (sample selectors, fixture recordings, `Request` usage).
  - Specify playback verification across Windows + Android when UX changes or shaders are involved.
  - Identify platform-specific behaviour and feature flags required for parity.
-->

### User Story 1 - Discover Official Metadata (Priority: P1)

Users browse anime catalog entries enriched with official metadata pulled from Bangumi and TMDb, ensuring titles, descriptions, artwork, and episode lists stay current without manual rule editing.

**Why this priority**: Accurate metadata underpins search, recommendations, and playback confidence; inconsistencies currently drive user confusion and duplicate entries across plugins.

**Independent Test**: Simulate metadata refresh for a single series and verify catalogue presentation in the library without enabling other stories.

**Acceptance Scenarios**:

1. **Given** an anime slug stored in Kazumi, **When** the metadata sync runs, **Then** the entry displays title, synopsis, and poster sourced from Bangumi or TMDb.
2. **Given** missing TMDb data for a title, **When** the sync fallback triggers, **Then** Bangumi metadata fills required fields without breaking catalogue layout.

---

### User Story 2 - Enhanced Playback Immersion (Priority: P2)

Viewers watch episodes with synchronized danmaku, Anime4K filters, subtitle auto-matching, and rate-adaptive playback without manual setup hurdles.

**Why this priority**: Playback features differentiate Kazumi; stabilizing them increases retention and showcases the platform's core strengths.

**Independent Test**: Play a single episode using the feature stack on Windows and Android and confirm danmaku, filters, and subtitles function without the metadata sync story enabled.

**Acceptance Scenarios**:

1. **Given** a supported video source, **When** the user enables Anime4K filters, **Then** the playback pipeline applies the effect without stutter or shader errors.
2. **Given** the episode has multiple subtitle matches, **When** auto-selection runs, **Then** the highest-confidence subtitle loads and can be switched manually if needed.

---

### User Story 3 - Unified Download & Library Control (Priority: P3)

Users queue downloads via aria2, monitor progress inside Kazumi, and see completed episodes classified within the library alongside watch history and preferences.

**Why this priority**: Integrated download control reduces reliance on external managers and ties offline viewing directly to playback history, improving continuity across devices.

**Independent Test**: Trigger a download for a single episode, monitor progress, and confirm classification updates without enabling metadata sync or playback enhancements.

**Acceptance Scenarios**:

1. **Given** aria2 is configured, **When** a user queues an episode download, **Then** progress appears in Kazumi with status updates and completion notifications.
2. **Given** an episode finishes downloading, **When** the user views the library, **Then** the episode appears in the appropriate category with watch history and preference tags updated.

---

### User Story 4 - Torrent (BT) Source Integration (Priority: P2)

Users browse torrent-based feeds exposed by plugins, review seeded file metadata, and launch downloads through aria2 or the configured BitTorrent backend without manual magnet handling.

**Why this priority**: Many anime sources distribute via torrents first; integrating these feeds keeps release parity and reduces the friction of switching apps.

**Independent Test**: Enable a torrent-capable plugin, load its episode list, inspect parsed trackers/seed counts, and trigger a magnet download that starts successfully in aria2 without editing the magnet URI.

**Acceptance Scenarios**:

1. **Given** a plugin exposes torrent selectors, **When** the user opens an episode, **Then** torrent metadata (size, seeders, trackers) renders alongside streaming options.
2. **Given** the user chooses the torrent option, **When** they confirm the download, **Then** Kazumi passes the magnet to aria2 with configured session cookies and reports progress within the unified queue.
3. **Given** aria2 rejects the magnet, **When** the user retries, **Then** Kazumi surfaces actionable error text and logs the failure for diagnostics without crashing the plugin flow.

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- How does the feature behave when a plugin response is empty, malformed, or violates `Api.apiLevel`?
- What happens when media-kit fails to initialize (e.g., missing shaders, codec unavailable)?
- How is user privacy preserved if sync or external player targets are unreachable?
- What fallback occurs on unsupported platforms (desktop vs. mobile)?
- What happens when torrent trackers or DHT endpoints are blocked, rate-limited, or require authentication mid-session?

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

- **FR-001**: System MUST ingest metadata from Bangumi and TMDb via the existing `Request` client, with fallbacks and rate limits documented in specs.
- **FR-002**: System MUST persist metadata, download states, and playback preferences in Hive boxes with retention aligned to the 24-hour cache promise or explicit opt-in overrides.
- **FR-003**: Playback experience MUST expose Anime4K filters, danmaku toggles, and subtitle auto-selection with graceful degradation when dependencies fail.
- **FR-004**: aria2 integration MUST surface queue management (start, pause, cancel) and progress reporting without exposing raw aria2 endpoints.
- **FR-005**: Library classification MUST sync watched status, download availability, and user preferences to keep cross-device history coherent.
- **FR-006**: Feature MUST enumerate platform support (Windows, Android, macOS, Linux) and gate platform-specific behaviour behind runtime checks.
- **FR-007**: Release documentation MUST highlight new privacy impacts, plugin validation steps, and manual verification performed for playback changes.

*Example of marking unclear requirements:*

- **FR-008**: Metadata display MUST follow device language → Bangumi (zh/ja) → English fallback, auto-enabling Bangumi only when the app locale is Chinese or Japanese and exposing user-configurable source toggles in settings.
- **FR-009**: aria2 download manager MUST default to two concurrent downloads and expose a user-configurable limit for simultaneous tasks, queuing additional items beyond that threshold.
- **FR-010**: Torrent-capable plugins MUST provide XPath selectors for magnet URIs, file sizes, and swarm statistics, and Kazumi MUST normalize the result into aria2-compatible requests including required cookies/headers before dispatch.
- **FR-011**: Torrent execution MUST remain behind an explicit user consent gate that records region-appropriate compliance messaging before enabling tracker or DHT communication.
- **FR-012**: Localization MUST leverage the `slang` framework with project scaffolding configured so that simplified Chinese ships as the default locale and additional locales can be generated via `slang` workflows.

### Key Entities *(include if feature involves data)*

- **MetadataSource**: Represents upstream providers (Bangumi, TMDb) with fields for API identifiers, last sync timestamps, supported language set, fallback order, and user-enabled toggles.
- **DownloadTask**: Captures aria2 task identifiers, episode associations, progress states, storage paths, retention flags, and the concurrency slot assigned when launched.
- **TorrentEntry**: Represents torrent payloads captured from plugins with magnet URI, info hash, tracker list, seed/leech counts, size metadata, plugin provenance, and consent flag state.
- **PlaybackProfile**: Stores user-selected danmaku settings, Anime4K presets, subtitle preferences, and per-device overrides.
- **LibraryEntry**: Aggregates metadata, download availability, watch history, and recommendation signals for a title or episode.

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: 95% of catalogue entries display complete titles, artwork, and episode lists after metadata sync without manual rule edits.
- **SC-002**: 90% of playback sessions maintain smooth Video + Anime4K + danmaku playback for at least 30 minutes on both Windows and Android during testing.
- **SC-003**: 85% of subtitle auto-matches align with the selected audio track without requiring manual correction in usability tests.
- **SC-004**: 80% of downloads initiated inside Kazumi complete successfully, with combined download/playback history remaining consistent across devices.

## Edge Cases

- Metadata provider unreachable: sync defers gracefully and surfaces status without blocking playback.
- Conflicting metadata between Bangumi and TMDb: system applies precedence rules and records provenance in `MetadataSource`.
- aria2 daemon offline: download queue provides retry guidance and does not lose queued tasks.
- Insufficient storage: download task alerts user, pauses queue, and maintains history state.
- Shader incompatibility on low-end GPUs: Anime4K gracefully disables while retaining playback.
- Magnet link malformed or blocked: system validates the magnet before submission, surfaces remediation tips, and keeps the aria2 queue consistent.

## Assumptions

- Users consent to metadata caching for 24 hours; longer retention requires explicit opt-in.
- aria2 daemon is user-provided and reachable over LAN or localhost with authentication handled outside Kazumi.
- Bangumi remains the primary metadata source; TMDb offers supplementary artwork and localization.
- Bangumi supplies Chinese and Japanese metadata; TMDb supports six languages and becomes sole source when the app locale falls outside zh/ja unless users override settings.
- Default aria2 concurrency is two tasks; users can raise or lower this limit through settings.
- Users expect consistent behaviour across Windows and Android; macOS/Linux receive best effort parity.
- Torrent usage complies with local laws and requires explicit user opt-in before any tracker or DHT communication begins.
- `slang` supplies all generated localization outputs, with simplified Chinese preloaded as the default language while additional locales rely on `slang` build steps.

## Clarifications

### Session 2025-10-28

- Q: Which language precedence should Kazumi apply when merging Bangumi and TMDb metadata? → A: Prefer device language; auto-enable Bangumi only for Chinese/Japanese locales and let users toggle sources.
- Q: What concurrent download limit should Kazumi enforce by default for aria2? → A: Start with two simultaneous downloads and allow users to pick their own limit.
