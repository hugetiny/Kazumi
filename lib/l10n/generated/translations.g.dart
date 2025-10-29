/// Generated file. Do not edit.
///
/// Original: lib/l10n
/// To regenerate, run: `dart run slang`
///
/// Locales: 1
/// Strings: 23
///
/// Built on 2025-10-28 at 14:47 UTC

// coverage:ignore-file
// ignore_for_file: type=lint, unused_element_parameter

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.zhCn;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.zhCn) // set locale
/// - Locale locale = AppLocale.zhCn.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.zhCn) // locale check
enum AppLocale with BaseAppLocale<AppLocale, AppTranslations> {
	zhCn(languageCode: 'zh', countryCode: 'CN', build: AppTranslations.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, AppTranslations> build;

	/// Gets current instance managed by [LocaleSettings].
	AppTranslations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
AppTranslations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = AppTranslations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, AppTranslations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, AppTranslations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, AppTranslations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	AppTranslations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, AppTranslations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, AppTranslations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class AppTranslations implements BaseTranslations<AppLocale, AppTranslations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = AppTranslations.of(context);
	static AppTranslations of(BuildContext context) => InheritedLocaleData.of<AppLocale, AppTranslations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	AppTranslations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.zhCn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-CN>.
	@override final TranslationMetadata<AppLocale, AppTranslations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final AppTranslations _root = this; // ignore: unused_field

	// Translations
	late final _TranslationsAppZhCn app = _TranslationsAppZhCn._(_root);
	late final _TranslationsMetadataZhCn metadata = _TranslationsMetadataZhCn._(_root);
	late final _TranslationsDownloadsZhCn downloads = _TranslationsDownloadsZhCn._(_root);
	late final _TranslationsTorrentZhCn torrent = _TranslationsTorrentZhCn._(_root);
	late final _TranslationsSettingsZhCn settings = _TranslationsSettingsZhCn._(_root);
}

// Path: app
class _TranslationsAppZhCn {
	_TranslationsAppZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => 'Kazumi';
	String get loading => '加载中…';
	String get retry => '重试';
	String get confirm => '确认';
	String get cancel => '取消';
}

// Path: metadata
class _TranslationsMetadataZhCn {
	_TranslationsMetadataZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get sectionTitle => '作品信息';
	String get refresh => '刷新元数据';
	late final _TranslationsMetadataSourceZhCn source = _TranslationsMetadataSourceZhCn._(_root);
	String get lastSynced => '上次同步：{timestamp}';
}

// Path: downloads
class _TranslationsDownloadsZhCn {
	_TranslationsDownloadsZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get sectionTitle => '下载队列';
	String get aria2Offline => 'aria2 未连接';
	String get queued => '排队';
	String get running => '下载中';
	String get completed => '已完成';
}

// Path: torrent
class _TranslationsTorrentZhCn {
	_TranslationsTorrentZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	late final _TranslationsTorrentConsentZhCn consent = _TranslationsTorrentConsentZhCn._(_root);
	late final _TranslationsTorrentErrorZhCn error = _TranslationsTorrentErrorZhCn._(_root);
}

// Path: settings
class _TranslationsSettingsZhCn {
	_TranslationsSettingsZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get metadata => '信息源设置';
	String get downloads => '下载设置';
	String get playback => '播放偏好';
}

// Path: metadata.source
class _TranslationsMetadataSourceZhCn {
	_TranslationsMetadataSourceZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get bangumi => 'Bangumi';
	String get tmdb => 'TMDb';
}

// Path: torrent.consent
class _TranslationsTorrentConsentZhCn {
	_TranslationsTorrentConsentZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => 'BitTorrent 使用提示';
	String get description => '启用 BT 下载前，请确认遵守所在地法律并了解使用风险。';
	String get agree => '我已知悉，继续';
	String get decline => '暂不开启';
}

// Path: torrent.error
class _TranslationsTorrentErrorZhCn {
	_TranslationsTorrentErrorZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get submit => '无法提交磁力链接，稍后重试';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on AppTranslations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'Kazumi';
			case 'app.loading': return '加载中…';
			case 'app.retry': return '重试';
			case 'app.confirm': return '确认';
			case 'app.cancel': return '取消';
			case 'metadata.sectionTitle': return '作品信息';
			case 'metadata.refresh': return '刷新元数据';
			case 'metadata.source.bangumi': return 'Bangumi';
			case 'metadata.source.tmdb': return 'TMDb';
			case 'metadata.lastSynced': return '上次同步：{timestamp}';
			case 'downloads.sectionTitle': return '下载队列';
			case 'downloads.aria2Offline': return 'aria2 未连接';
			case 'downloads.queued': return '排队';
			case 'downloads.running': return '下载中';
			case 'downloads.completed': return '已完成';
			case 'torrent.consent.title': return 'BitTorrent 使用提示';
			case 'torrent.consent.description': return '启用 BT 下载前，请确认遵守所在地法律并了解使用风险。';
			case 'torrent.consent.agree': return '我已知悉，继续';
			case 'torrent.consent.decline': return '暂不开启';
			case 'torrent.error.submit': return '无法提交磁力链接，稍后重试';
			case 'settings.metadata': return '信息源设置';
			case 'settings.downloads': return '下载设置';
			case 'settings.playback': return '播放偏好';
			default: return null;
		}
	}
}
