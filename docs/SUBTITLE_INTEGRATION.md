# Subtitle Auto-Match Integration Guide

## Overview
The subtitle auto-matching feature provides automatic subtitle selection based on language preferences and confidence scoring. The core module (`SubtitleMatcher`) is implemented and ready for integration with the player UI.

## Implementation Status

### ✅ Completed
- **Core Module**: `lib/modules/playback/subtitle_matcher.dart`
  - Heuristic-based subtitle selection
  - Language and format preference scoring
  - Subtitle download and validation
  - API response parsing helpers

- **Storage Configuration**: `lib/utils/storage.dart`
  - `subtitleAutoMatchEnabled`: Toggle auto-matching on/off
  - `subtitlePreferredLanguages`: List of preferred languages (e.g., ['zh-CN', 'en-US'])
  - `subtitlePreferredFormats`: List of preferred formats (e.g., ['ass', 'srt', 'vtt'])

### ⏳ Pending Integration
The following steps are needed to fully integrate subtitle auto-matching into the player:

1. **Update Player State** (`lib/pages/player/player_state.dart`)
   - Add subtitle-related fields:
     ```dart
     @Default([]) List<SubtitleMatch> availableSubtitles,
     @Default(null) SubtitleMatch? selectedSubtitle,
     @Default(true) bool subtitleAutoMatchEnabled,
     ```

2. **Update Player Controller** (`lib/pages/player/player_controller.dart`)
   - Import `SubtitleMatcher`
   - Initialize subtitle matcher in controller
   - Fetch subtitle candidates when video loads
   - Auto-select best match based on preferences
   - Apply subtitle to media-kit player

3. **Update Player UI** (`lib/pages/player/player_item.dart`)
   - Add subtitle selection button
   - Show current subtitle language
   - Allow manual subtitle switching

4. **Settings UI** (`lib/pages/settings/player_settings.dart`)
   - Toggle for subtitle auto-matching
   - Language preference selection
   - Format preference selection

## Usage Example

### Basic Subtitle Selection
```dart
import 'package:kazumi/modules/playback/subtitle_matcher.dart';
import 'package:kazumi/utils/storage.dart';

// Initialize matcher
final matcher = SubtitleMatcher();

// Get user preferences from settings
final preferredLanguages = GStorage.setting.get(
  SettingBoxKey.subtitlePreferredLanguages,
  defaultValue: ['zh-CN', 'en-US'],
) as List<String>;

// Sample subtitle candidates
final candidates = [
  SubtitleMatch(
    url: 'https://example.com/subtitles/zh-cn.ass',
    language: 'zh-CN',
    confidence: 0.9,
    format: 'ass',
  ),
  SubtitleMatch(
    url: 'https://example.com/subtitles/en-us.srt',
    language: 'en-US',
    confidence: 0.8,
    format: 'srt',
  ),
];

// Select best match
final bestMatch = matcher.selectBestMatch(
  candidates,
  preferredLanguages: preferredLanguages,
);

if (bestMatch != null) {
  // Download subtitle
  final subtitleFile = await matcher.downloadSubtitle(
    bestMatch.url,
    '/path/to/save/subtitle.${bestMatch.format}',
  );
  
  if (subtitleFile != null) {
    // Apply to player (media-kit specific)
    // player.setSubtitleFile(subtitleFile.path);
  }
}
```

### API Integration Example

**Note**: This is a placeholder example showing how to parse subtitle data from external APIs. Actual subtitle API integration (OpenSubtitles, SubDB, etc.) is pending future work. The `fromApiResponse` helper method is designed to make such integration straightforward once APIs are connected.

```dart
// Parse subtitle candidates from external API
final apiResponse = [
  {
    'url': 'https://api.example.com/sub/12345',
    'language': 'zh-CN',
    'confidence': 0.95,
    'source': 'SubDB',
  },
  {
    'url': 'https://api.example.com/sub/67890',
    'language': 'en-US',
    'confidence': 0.85,
    'source': 'OpenSubtitles',
  },
];

final matches = SubtitleMatcher.fromApiResponse(
  apiResponse.cast<Map<String, dynamic>>(),
);

final bestMatch = matcher.selectBestMatch(matches);
```

## Configuration

### Default Settings
When a user first enables subtitle auto-matching, the following defaults are used:

- **Auto-match enabled**: `false` (user must opt-in)
- **Preferred languages**: `['zh-CN', 'en-US']` (Chinese first, English fallback)
- **Preferred formats**: `['ass', 'srt', 'vtt']` (ASS for styling, SRT for compatibility, VTT for web)

### Settings Storage
```dart
// Enable subtitle auto-matching
await GStorage.setting.put(SettingBoxKey.subtitleAutoMatchEnabled, true);

// Set language preferences
await GStorage.setting.put(
  SettingBoxKey.subtitlePreferredLanguages,
  ['zh-CN', 'en-US', 'ja-JP'],
);

// Set format preferences
await GStorage.setting.put(
  SettingBoxKey.subtitlePreferredFormats,
  ['ass', 'srt'],
);
```

## Scoring Algorithm

The subtitle matcher uses a weighted scoring system:

1. **Base Confidence**: From subtitle source (0.0-1.0)
2. **Language Bonus**: +0.2 per position in preference list
   - 1st choice: +0.6 (3 positions * 0.2)
   - 2nd choice: +0.4 (2 positions * 0.2)
   - 3rd choice: +0.2 (1 position * 0.2)
3. **Format Bonus**: +0.1 per position in format list
   - 1st choice: +0.3 (3 positions * 0.1)
   - 2nd choice: +0.2 (2 positions * 0.1)
   - 3rd choice: +0.1 (1 position * 0.1)

### Example Scoring
Given preferences: `languages=['zh-CN', 'en-US']`, `formats=['ass', 'srt']`

| Subtitle | Base | Language | Format | Total |
|----------|------|----------|--------|-------|
| zh-CN ASS 0.9 | 0.9 | +0.4 | +0.2 | 1.5 |
| en-US SRT 0.8 | 0.8 | +0.2 | +0.1 | 1.1 |
| ja-JP ASS 0.95 | 0.95 | +0.0 | +0.2 | 1.15 |

Winner: zh-CN ASS (score: 1.5)

## Testing Recommendations

### Unit Tests
Create `test/unit/subtitle_matcher_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/modules/playback/subtitle_matcher.dart';

void main() {
  group('SubtitleMatcher', () {
    late SubtitleMatcher matcher;

    setUp(() {
      matcher = SubtitleMatcher();
    });

    test('selects highest-scored subtitle', () {
      final candidates = [
        SubtitleMatch(
          url: 'http://example.com/zh.ass',
          language: 'zh-CN',
          confidence: 0.9,
          format: 'ass',
        ),
        SubtitleMatch(
          url: 'http://example.com/en.srt',
          language: 'en-US',
          confidence: 0.8,
          format: 'srt',
        ),
      ];

      final result = matcher.selectBestMatch(
        candidates,
        preferredLanguages: ['zh-CN', 'en-US'],
        preferredFormats: ['ass', 'srt'],
      );

      expect(result?.language, 'zh-CN');
      expect(result?.format, 'ass');
    });

    test('returns null for empty candidates', () {
      final result = matcher.selectBestMatch([]);
      expect(result, isNull);
    });
  });
}
```

### Integration Tests
- Test with real subtitle APIs (OpenSubtitles, SubDB, etc.)
- Verify download and file validation
- Test error handling for network failures

## Future Enhancements

1. **Subtitle Search Integration**
   - Integrate with OpenSubtitles API
   - Support for SubDB and other providers
   - Hash-based subtitle matching

2. **Advanced Matching**
   - Fuzzy matching on episode titles
   - Release group matching
   - Frame rate detection and adjustment

3. **Subtitle Caching**
   - Cache downloaded subtitles
   - Reuse for rewatching
   - Automatic cleanup based on age

4. **Quality Metrics**
   - User ratings for subtitle quality
   - Hearing impaired (SDH) detection
   - Sync quality indicators

## References

- [OpenSubtitles API](https://www.opensubtitles.org/en/search/sublanguageid-all)
- [SubDB](http://thesubdb.com/)
- [ASS Format Specification](http://www.matroska.org/technical/specs/subtitles/ssa.html)
- [WebVTT Specification](https://www.w3.org/TR/webvtt1/)
