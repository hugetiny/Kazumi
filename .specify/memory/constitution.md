<!--
Sync Impact Report
Version change: 0.0.0 → 1.0.0
Modified principles: (new) I. Privacy-First Client; (new) II. Plugin Safety & Compatibility; (new) III. Playback Integrity; (new) IV. Cross-Platform Confidence; (new) V. Specification-Driven Delivery
Added sections: Core Principles; Operational Constraints; Development Workflow; Governance
Removed sections: None
Templates requiring updates:
- ✅ .specify/templates/plan-template.md
- ✅ .specify/templates/spec-template.md
- ✅ .specify/templates/tasks-template.md
Follow-up TODOs: None
-->

# Kazumi Constitution

## Core Principles

### I. Privacy-First Client
- MUST NOT introduce telemetry, third-party analytics, or remote logging beyond controlled `KazumiLogger` usage; any persisted data requires explicit documentation in specs and `GStorage` migrations.
- MUST limit retention of scraped media and caches to the 24-hour window promised in the README and expose opt-in toggles when extending storage or sync scopes.
- SHOULD default new sync or export features (e.g., WebDAV, external players) to explicit user consent flows before transferring personal data.

Rationale: The README and privacy policy guarantee zero data collection; preserving that promise sustains community trust and shields contributors from legal exposure.

### II. Plugin Safety & Compatibility
- MUST validate each plugin or rule update against `Api.apiLevel`, populate required selectors, and log compatibility outcomes with `KazumiLogger` before distribution.
- MUST route all scraper networking through the shared `Request` helper to inherit randomized headers, proxy toggles, and error handling; direct `Dio` usage is prohibited until upstreamed into `Request`.
- MUST ship regression fixtures (e.g., example responses or updated `assets/plugins/*.json`) and migration notes whenever plugin schemas or selector semantics change.

Rationale: Plugins power discovery; unchecked selectors break playback, expose users to malicious payloads, and fragment the ecosystem.

### III. Playback Integrity
- MUST preserve the media-kit pipeline, danmaku integrations, and shader setup; changes touching `PlayerController`, `VideoController`, or shader assets require smoke tests on Windows desktop and Android before merge.
- MUST provide guarded fallbacks when optional capabilities (Anime4K, SyncPlay, DLNA, external players) are unavailable so that playback gracefully degrades instead of aborting sessions.
- MUST document manual or automated verification steps for playlist retrieval, road switching, and buffering whenever altering plugin-video integration paths.

Rationale: Playback quality is the core product experience; regressions immediately erode user confidence.

### IV. Cross-Platform Confidence
- MUST ensure new features compile and run on Windows and Android; platform-exclusive behaviour must be feature-flagged and guarded by runtime checks.
- MUST encapsulate platform-specific code behind dedicated adapters (e.g., `lib/utils/platform.dart` or module-level services) to keep shared business logic portable.
- SHOULD capture build or deployment prerequisites (window chrome, iOS signing, Linux packaging) inside specs when touched to unblock downstream maintainers.

Rationale: The app ships across desktop and mobile; parity prevents fragmenting the plugin community and simplifies support.

### V. Specification-Driven Delivery
- MUST execute `/speckit.spec`, `/speckit.plan`, and `/speckit.tasks` (or document leadership-approved exceptions) before implementing net-new capabilities.
- MUST keep generated artifacts (`*.g.dart`, `*.freezed.dart`) in sync via `flutter pub run build_runner build --delete-conflicting-outputs` prior to review.
- MUST include acceptance evidence—automated tests or documented manual steps—within PR descriptions mapped to the relevant user stories.

Rationale: Structured planning and verification are required to manage a complex scraping and playback stack without regressions.

## Operational Constraints

- Flutter with Riverpod powers all feature modules; new pages must expose notifiers through their `providers.dart` companion and register with `lib/providers/providers.dart` when shared.
- Persistent storage relies on Hive via `GStorage`; schema changes demand migration scripts, WebDAV sync compatibility checks, and versioned release notes.
- Networking must use the `Request` wrapper and `ApiInterceptor` to honor proxy toggles, randomize headers, and centralize error handling; bypassing these layers is not permitted.
- Media playback depends on `media-kit`, `ShadersController`, and `SyncPlay`; new shader assets live under `assets/shaders/` with corresponding copy steps in initialization controllers.

## Development Workflow

1. Initiate features with a constitution check in the implementation plan, confirming compliance with all core principles before Phase 0 research.
2. Produce specs and plans that call out platform coverage, plugin validation strategy, storage impacts, and verification evidence for every user story.
3. Run `flutter analyze`, `flutter test`, and `flutter pub run build_runner build --delete-conflicting-outputs` ahead of review; document manual smoke tests for platform or playback changes.
4. Ensure release notes, plugin fixtures, and onboarding copy stay aligned with updated behaviour before tagging releases or publishing plugin updates.

## Governance

- This constitution supersedes other process documents; maintainers enforce compliance during review, blocking work that violates core principles.
- Amendments require an RFC summarizing proposed changes, principle impacts, and mitigation plans; approvers are the repository owner plus at least one core maintainer.
- Versioning follows semantic rules: MAJOR for adding/removing principles or redefining governance, MINOR for new guidance or sections, PATCH for clarifications.
- Compliance reviews audit adherence quarterly or after major releases, logging findings in `.specify/memory/` for traceability.

**Version**: 1.0.0 | **Ratified**: 2025-10-28 | **Last Amended**: 2025-10-28
