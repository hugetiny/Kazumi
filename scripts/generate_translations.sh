#!/bin/bash

# Translation Generation Script for Kazumi
# This script regenerates translation files using slang

set -e

echo "🌐 Kazumi Translation Generator"
echo "================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "   Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✓ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Navigate to project root
cd "$(dirname "$0")/.."

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run slang to generate translations
echo "🔄 Generating translations..."
dart run slang

# Check if generation was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Translations generated successfully!"
    echo "   Generated file: lib/l10n/generated/translations.g.dart"
    
    # Count locales and strings
    LOCALES=$(grep -c "@@locale" lib/l10n/*.i18n.json)
    echo "   Locales: $LOCALES"
    
    # Show file info
    echo ""
    echo "📊 Generated file info:"
    head -10 lib/l10n/generated/translations.g.dart | grep -E "Locales:|Strings:|Built on"
else
    echo ""
    echo "❌ Translation generation failed!"
    echo "   Please check the error messages above."
    exit 1
fi

echo ""
echo "💡 Tip: Run 'flutter pub run slang' or 'dart run slang' directly for more options"
echo "📖 Documentation: docs/i18n.md"
