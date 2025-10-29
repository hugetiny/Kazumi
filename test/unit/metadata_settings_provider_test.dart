import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/pages/setting/providers.dart';
import 'package:kazumi/utils/storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<dynamic> box;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('metadata_settings_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('setting');
    GStorage.setting = box;
  });

  tearDown(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('setting');
    await tempDir.delete(recursive: true);
  });

  test('metadata settings default to enabled sources', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final MetadataSettingsState state =
        container.read(metadataSettingsProvider);

    expect(state.bangumiEnabled, isTrue);
    expect(state.tmdbEnabled, isTrue);
    expect(state.manualLocaleTag, isNull);
  });

  test('toggling metadata source persists to storage', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final MetadataSettingsNotifier notifier =
        container.read(metadataSettingsProvider.notifier);

    await notifier.setBangumiEnabled(false);
    await notifier.setTmdbEnabled(false);

    final MetadataSettingsState state =
        container.read(metadataSettingsProvider);

    expect(state.bangumiEnabled, isFalse);
    expect(state.tmdbEnabled, isFalse);
    expect(GStorage.setting.get(SettingBoxKey.metadataBangumiEnabled), isFalse);
    expect(GStorage.setting.get(SettingBoxKey.metadataTmdbEnabled), isFalse);
  });

  test('manual locale updates dashed tag and supports clearing', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final MetadataSettingsNotifier notifier =
        container.read(metadataSettingsProvider.notifier);

    await notifier.setManualLocale('ja-JP');
    expect(GStorage.setting.get(SettingBoxKey.metadataPreferredLocale), 'ja-JP');

    MetadataSettingsState state =
        container.read(metadataSettingsProvider);
    expect(state.manualLocaleTag, 'ja-JP');

    await notifier.setManualLocale(null);
    expect(GStorage.setting.get(SettingBoxKey.metadataPreferredLocale), '');

    state = container.read(metadataSettingsProvider);
    expect(state.manualLocaleTag, isNull);
  });
}
