# Data Model: Kazumi Media Experience Suite

## Entities

### MetadataSource
- **Description**: Configuration and state for upstream metadata providers.
- **Fields**:
  - `id` (String) – Identifier for the provider (`bangumi`, `tmdb`).
  - `enabled` (bool) – User toggle for enabling the provider.
  - `supportedLanguages` (List<String>) – ISO language codes served by the provider.
  - `fallbackOrder` (int) – Priority order relative to other sources.
  - `lastSyncedAt` (DateTime) – Timestamp of most recent successful sync.
  - `rateLimitWindow` (Duration) – Cool-down before requesting again.
- **Relationships**: Linked to `LibraryEntry` via source attribution.
- **Validation**: `fallbackOrder` must be unique; `supportedLanguages` cannot be empty when `enabled` is true.

### LibraryEntry
- **Description**: Represents an anime title or episode within Kazumi’s catalog.
- **Fields**:
  - `slug` (String) – Unique key across metadata sources.
  - `title` (LocalizedText) – Map of language code → localized title.
  - `synopsis` (LocalizedText) – Map of language code → plot summary.
  - `posterUrl` (String) – Artwork URL with provenance.
  - `episodes` (List<EpisodeRef>) – Ordered list referencing episode metadata.
  - `metadataSource` (String) – Source identifier providing current data.
  - `updatedAt` (DateTime) – Last metadata refresh timestamp.
  - `watchHistory` (WatchState) – Aggregated playback status.
  - `downloadAvailability` (DownloadState) – Summaries of local/offline availability.
- **Relationships**: Consumes `MetadataSource` data; referenced by `DownloadTask` and `PlaybackProfile`.
- **Validation**: `slug` unique; `episodes` must align with metadata source episode count.

### DownloadTask
- **Description**: Tracks aria2-managed downloads linked to library entries.
- **Fields**:
  - `taskId` (String) – aria2 GID.
  - `entrySlug` (String) – Foreign key to `LibraryEntry`.
  - `episodeNumber` (int) – Episode index for reference.
  - `sourceKind` (enum: direct, torrent) – Differentiates HTTP downloads from torrent-backed magnets.
  - `torrentInfoHash` (String?) – Populated when `sourceKind` is `torrent`.
  - `status` (enum: queued, running, paused, completed, failed)
  - `progress` (double 0–1)
  - `savePath` (String)
  - `concurrencySlot` (int) – Slot assigned when running.
  - `requestedAt` (DateTime)
  - `completedAt` (DateTime?)
- **Relationships**: One-to-many from `LibraryEntry`.
- **Validation**: `concurrencySlot` must not exceed configured maximum; `progress` bounded 0–1.

### TorrentEntry
- **Description**: Captures torrent metadata discovered through plugins before submission to aria2.
- **Fields**:
  - `infoHash` (String) – Unique torrent identifier derived from the magnet.
  - `magnetUri` (String) – Normalized magnet including trackers and params.
  - `trackers` (List<String>) – Tracker URLs scraped from the plugin.
  - `seeders` (int)
  - `leechers` (int)
  - `sizeBytes` (int)
  - `pluginId` (String) – Provenance for audit and debugging.
  - `consentGrantedAt` (DateTime?) – Timestamp when user enabled torrent access.
- **Relationships**: Links to `DownloadTask` when `sourceKind` is `torrent`; references `LibraryEntry` for episode context.
- **Validation**: `magnetUri` must include `xt=urn:btih`; trackers sanitized to supported protocols.

### PlaybackProfile
- **Description**: Per-device playback preferences and session state.
- **Fields**:
  - `deviceId` (String) – Unique identifier for platform/device.
  - `danmakuEnabled` (bool)
  - `anime4kPreset` (enum: off, fast, quality)
  - `subtitleLanguageOrder` (List<String>)
  - `lastKnownRoad` (String?) – Last playback source path.
  - `syncPlayEnabled` (bool)
  - `updatedAt` (DateTime)
- **Relationships**: Associated with `LibraryEntry` watch sessions; informs `PlayerController`.
- **Validation**: `subtitleLanguageOrder` must include at least one language; `anime4kPreset` must map to known shader pipeline.

### WatchState (Value Object)
- **Fields**:
  - `currentEpisode` (int)
  - `position` (Duration)
  - `completedEpisodes` (List<int>)
  - `lastWatchedAt` (DateTime)

### DownloadState (Value Object)
- **Fields**:
  - `availableEpisodes` (List<int>)
  - `lastSyncedAt` (DateTime)
  - `storageFootprint` (int, MB)

## State Transitions

- `DownloadTask.status`: queued → running (slot assigned) → completed/failed; running → paused → running.
- `LibraryEntry.metadataSource`: switches when fallback logic promotes TMDb or Bangumi based on locale changes; triggers `updatedAt` refresh.
- `PlaybackProfile.anime4kPreset`: updated via settings; changing to unsupported preset on platform forces downgrade to `fast` preset with log entry.

## Retention & Privacy

- Metadata snapshots older than 24 hours are purged unless user opt-in is enabled.
- Download state retains completed tasks for 24 hours after completion unless file persists locally; anonymized metrics only stored in-memory for analytics-free compliance.
- Torrent tracker lists are cached only for active sessions and cleared when consent is revoked or after 24 hours of inactivity.
