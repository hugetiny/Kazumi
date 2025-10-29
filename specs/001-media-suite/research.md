# Research: Kazumi Media Experience Suite

## Playback Smoke Test Matrix
- **Decision**: Validate playback on Windows (hardware acceleration on/off) and Android (mid-tier + high-tier devices) covering Anime4K shaders, danmaku rendering, and subtitle auto-match within 30-minute sessions.
- **Rationale**: media-kit relies on platform codecs; exercising both GPU and software paths on desktop plus representative Android hardware catches shader and buffering regressions early.
- **Alternatives Considered**:
  - Test only on Windows (Rejected: misses Android decoder variations).
  - Rely purely on automated widget tests (Rejected: cannot cover hardware-dependent playback paths).

## Metadata Source Precedence
- **Decision**: Prefer device locale, enable Bangumi metadata only for zh/ja locales by default, fall back to TMDb English when localized data missing, and allow user-configurable source toggles.
- **Rationale**: Aligns with localization expectations while acknowledging Bangumi’s limited language coverage; user overrides preserve flexibility.
- **Alternatives Considered**:
  - Always use Bangumi and supplement with TMDb artwork (Rejected: poor experience for non-zh/ja users).
  - Make TMDb primary for all locales (Rejected: loses authoritative anime catalog data Bangumi provides).

## aria2 Concurrency Strategy
- **Decision**: Default to 2 concurrent aria2 downloads with adjustable limit stored in settings and enforced client-side.
- **Rationale**: Matches aria2 best-practice defaults, prevents bandwidth contention on mobile, and honors specification requirement for user overrides.
- **Alternatives Considered**:
  - Unlimited concurrency (Rejected: risks exhausting network/storage).
  - Single-download queue (Rejected: under-utilizes desktop bandwidth).

## Metadata Cache Retention
- **Decision**: Persist metadata snapshots in Hive with timestamped entries, trigger refresh every 24 hours or on-demand, and expose manual refresh in settings.
- **Rationale**: Complies with privacy promise while letting users refresh stale entries; Hive timestamps simplify retention enforcement.
- **Alternatives Considered**:
  - Persistent indefinite cache (Rejected: violates 24-hour policy).
  - Fetch-on-demand only (Rejected: increases latency and API load).
