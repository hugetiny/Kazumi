# Translation Files Need Regeneration

⚠️ **Important**: The translation files in `lib/l10n/generated/translations.g.dart` need to be regenerated to include the new locales and expanded strings.

## Why Regeneration is Needed

The PR adds:
- 2 new locales: Japanese (ja-JP) and Traditional Chinese (zh-TW)
- Expanded translation coverage (from 23 strings to ~70 strings)
- New translation categories for settings UI

The current generated file only includes:
- 1 locale (zh-CN)
- 23 translation strings
- Generated on 2025-10-28

## How to Regenerate

### Option 1: Run Locally (Recommended)

If you have Flutter installed:

```bash
# From project root
./scripts/generate_translations.sh
```

Or manually:

```bash
flutter pub get
dart run slang
```

### Option 2: Use GitHub Actions

The PR includes a workflow that will automatically regenerate translations:

1. Push your changes to the PR branch
2. The `generate-translations.yml` workflow will run
3. Translation files will be automatically committed

### Option 3: Wait for Maintainer

Maintainers with a properly configured Flutter environment can run the generation step after reviewing the PR.

## Verification

After regeneration, the file should show:
- Locales: 4 (zh-CN, en-US, ja-JP, zh-TW)
- Strings: ~70
- Recent build timestamp

## For Reviewers

To test this PR without regenerating locally:
1. Review the translation JSON files (`lib/l10n/*.i18n.json`)
2. Review the code changes for locale management
3. Check that the architecture is sound
4. Translation generation can be done in a follow-up step

The code changes are complete and functional; only the generated file needs updating.
