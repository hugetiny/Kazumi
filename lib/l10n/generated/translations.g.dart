/// Generated file. Do not edit.
///
/// Original: lib/l10n
/// To regenerate, run: `dart run slang`
///
/// Locales: 4
/// Strings: 272 (68 per locale)
///
/// Built on 2025-10-29 at 19:33 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

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
	zhCn(languageCode: 'zh', countryCode: 'CN', build: AppTranslations.build),
	enUs(languageCode: 'en', countryCode: 'US', build: _TranslationsEnUs.build),
	jaJp(languageCode: 'ja', countryCode: 'JP', build: _TranslationsJaJp.build),
	zhTw(languageCode: 'zh', countryCode: 'TW', build: _TranslationsZhTw.build);

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
	late final _TranslationsExitDialogZhCn exitDialog = _TranslationsExitDialogZhCn._(_root);
	late final _TranslationsTrayZhCn tray = _TranslationsTrayZhCn._(_root);
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
	String get title => '设置';
	late final _TranslationsSettingsMetadataZhCn metadata = _TranslationsSettingsMetadataZhCn._(_root);
	String get downloads => '下载设置';
	String get playback => '播放偏好';
	late final _TranslationsSettingsGeneralZhCn general = _TranslationsSettingsGeneralZhCn._(_root);
	late final _TranslationsSettingsSourceZhCn source = _TranslationsSettingsSourceZhCn._(_root);
	late final _TranslationsSettingsPlayerZhCn player = _TranslationsSettingsPlayerZhCn._(_root);
	late final _TranslationsSettingsWebdavZhCn webdav = _TranslationsSettingsWebdavZhCn._(_root);
	late final _TranslationsSettingsOtherZhCn other = _TranslationsSettingsOtherZhCn._(_root);
}

// Path: exitDialog
class _TranslationsExitDialogZhCn {
	_TranslationsExitDialogZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => '退出确认';
	String get message => '您想要退出 Kazumi 吗？';
	String get dontAskAgain => '下次不再询问';
	String get exit => '退出 Kazumi';
	String get minimize => '最小化至托盘';
	String get cancel => '取消';
}

// Path: tray
class _TranslationsTrayZhCn {
	_TranslationsTrayZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get showWindow => '显示窗口';
	String get exit => '退出 Kazumi';
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

// Path: settings.metadata
class _TranslationsSettingsMetadataZhCn {
	_TranslationsSettingsMetadataZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => '元数据';
	String get enableBangumi => '启用 Bangumi 元数据';
	String get enableBangumiDesc => '从 Bangumi 拉取番剧信息';
	String get enableTmdb => '启用 TMDb 元数据';
	String get enableTmdbDesc => '从 TMDb 补充多语言资料';
	String get preferredLanguage => '优先语言';
	String get preferredLanguageDesc => '设置元数据同步时使用的语言';
	String get followSystemLanguage => '跟随系统语言';
	String get simplifiedChinese => '简体中文 (zh-CN)';
	String get traditionalChinese => '繁體中文 (zh-TW)';
	String get japanese => '日语 (ja-JP)';
	String get english => '英语 (en-US)';
	String get custom => '自定义';
}

// Path: settings.general
class _TranslationsSettingsGeneralZhCn {
	_TranslationsSettingsGeneralZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => '通用';
	String get appearance => '外观设置';
	String get appearanceDesc => '设置应用主题和刷新率';
	String get language => '应用语言';
	String get languageDesc => '选择应用界面显示语言';
	String get followSystem => '跟随系统';
	String get exitBehavior => '关闭时';
	String get exitApp => '退出 Kazumi';
	String get minimizeToTray => '最小化至托盘';
	String get askEveryTime => '每次都询问';
}

// Path: settings.source
class _TranslationsSettingsSourceZhCn {
	_TranslationsSettingsSourceZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => '源';
	String get ruleManagement => '规则管理';
	String get ruleManagementDesc => '管理番剧资源规则';
	String get githubProxy => 'Github 镜像';
	String get githubProxyDesc => '使用镜像访问规则托管仓库';
}

// Path: settings.player
class _TranslationsSettingsPlayerZhCn {
	_TranslationsSettingsPlayerZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => '播放器设置';
	String get playerSettings => '播放设置';
	String get playerSettingsDesc => '设置播放器相关参数';
	String get danmakuSettings => '弹幕设置';
	String get danmakuSettingsDesc => '设置弹幕相关参数';
}

// Path: settings.webdav
class _TranslationsSettingsWebdavZhCn {
	_TranslationsSettingsWebdavZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => 'WebDAV';
	String get desc => '设置同步参数';
}

// Path: settings.other
class _TranslationsSettingsOtherZhCn {
	_TranslationsSettingsOtherZhCn._(this._root);

	final AppTranslations _root; // ignore: unused_field

	// Translations
	String get title => '其他';
	String get about => '关于';
}

// Path: <root>
class _TranslationsEnUs extends AppTranslations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsEnUs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.enUs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en-US>.
	@override final TranslationMetadata<AppLocale, AppTranslations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _TranslationsEnUs _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsAppEnUs app = _TranslationsAppEnUs._(_root);
	@override late final _TranslationsMetadataEnUs metadata = _TranslationsMetadataEnUs._(_root);
	@override late final _TranslationsDownloadsEnUs downloads = _TranslationsDownloadsEnUs._(_root);
	@override late final _TranslationsTorrentEnUs torrent = _TranslationsTorrentEnUs._(_root);
	@override late final _TranslationsSettingsEnUs settings = _TranslationsSettingsEnUs._(_root);
	@override late final _TranslationsExitDialogEnUs exitDialog = _TranslationsExitDialogEnUs._(_root);
	@override late final _TranslationsTrayEnUs tray = _TranslationsTrayEnUs._(_root);
}

// Path: app
class _TranslationsAppEnUs extends _TranslationsAppZhCn {
	_TranslationsAppEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kazumi';
	@override String get loading => 'Loading…';
	@override String get retry => 'Retry';
	@override String get confirm => 'Confirm';
	@override String get cancel => 'Cancel';
}

// Path: metadata
class _TranslationsMetadataEnUs extends _TranslationsMetadataZhCn {
	_TranslationsMetadataEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'Media Information';
	@override String get refresh => 'Refresh Metadata';
	@override late final _TranslationsMetadataSourceEnUs source = _TranslationsMetadataSourceEnUs._(_root);
	@override String get lastSynced => 'Last synced: {timestamp}';
}

// Path: downloads
class _TranslationsDownloadsEnUs extends _TranslationsDownloadsZhCn {
	_TranslationsDownloadsEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'Download Queue';
	@override String get aria2Offline => 'aria2 not connected';
	@override String get queued => 'Queued';
	@override String get running => 'Downloading';
	@override String get completed => 'Completed';
}

// Path: torrent
class _TranslationsTorrentEnUs extends _TranslationsTorrentZhCn {
	_TranslationsTorrentEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTorrentConsentEnUs consent = _TranslationsTorrentConsentEnUs._(_root);
	@override late final _TranslationsTorrentErrorEnUs error = _TranslationsTorrentErrorEnUs._(_root);
}

// Path: settings
class _TranslationsSettingsEnUs extends _TranslationsSettingsZhCn {
	_TranslationsSettingsEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override late final _TranslationsSettingsMetadataEnUs metadata = _TranslationsSettingsMetadataEnUs._(_root);
	@override String get downloads => 'Download Settings';
	@override String get playback => 'Playback Preferences';
	@override late final _TranslationsSettingsGeneralEnUs general = _TranslationsSettingsGeneralEnUs._(_root);
	@override late final _TranslationsSettingsSourceEnUs source = _TranslationsSettingsSourceEnUs._(_root);
	@override late final _TranslationsSettingsPlayerEnUs player = _TranslationsSettingsPlayerEnUs._(_root);
	@override late final _TranslationsSettingsWebdavEnUs webdav = _TranslationsSettingsWebdavEnUs._(_root);
	@override late final _TranslationsSettingsOtherEnUs other = _TranslationsSettingsOtherEnUs._(_root);
}

// Path: exitDialog
class _TranslationsExitDialogEnUs extends _TranslationsExitDialogZhCn {
	_TranslationsExitDialogEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Exit Confirmation';
	@override String get message => 'Do you want to exit Kazumi?';
	@override String get dontAskAgain => 'Don\'t ask again';
	@override String get exit => 'Exit Kazumi';
	@override String get minimize => 'Minimize to Tray';
	@override String get cancel => 'Cancel';
}

// Path: tray
class _TranslationsTrayEnUs extends _TranslationsTrayZhCn {
	_TranslationsTrayEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get showWindow => 'Show Window';
	@override String get exit => 'Exit Kazumi';
}

// Path: metadata.source
class _TranslationsMetadataSourceEnUs extends _TranslationsMetadataSourceZhCn {
	_TranslationsMetadataSourceEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get bangumi => 'Bangumi';
	@override String get tmdb => 'TMDb';
}

// Path: torrent.consent
class _TranslationsTorrentConsentEnUs extends _TranslationsTorrentConsentZhCn {
	_TranslationsTorrentConsentEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'BitTorrent Usage Notice';
	@override String get description => 'Before enabling BT downloads, please confirm compliance with local laws and understand the risks involved.';
	@override String get agree => 'I understand, continue';
	@override String get decline => 'Not now';
}

// Path: torrent.error
class _TranslationsTorrentErrorEnUs extends _TranslationsTorrentErrorZhCn {
	_TranslationsTorrentErrorEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get submit => 'Unable to submit magnet link, please try again later';
}

// Path: settings.metadata
class _TranslationsSettingsMetadataEnUs extends _TranslationsSettingsMetadataZhCn {
	_TranslationsSettingsMetadataEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Metadata';
	@override String get enableBangumi => 'Enable Bangumi Metadata';
	@override String get enableBangumiDesc => 'Fetch anime information from Bangumi';
	@override String get enableTmdb => 'Enable TMDb Metadata';
	@override String get enableTmdbDesc => 'Supplement multilingual data from TMDb';
	@override String get preferredLanguage => 'Preferred Language';
	@override String get preferredLanguageDesc => 'Set the language for metadata synchronization';
	@override String get followSystemLanguage => 'Follow System Language';
	@override String get simplifiedChinese => 'Simplified Chinese (zh-CN)';
	@override String get traditionalChinese => 'Traditional Chinese (zh-TW)';
	@override String get japanese => 'Japanese (ja-JP)';
	@override String get english => 'English (en-US)';
	@override String get custom => 'Custom';
}

// Path: settings.general
class _TranslationsSettingsGeneralEnUs extends _TranslationsSettingsGeneralZhCn {
	_TranslationsSettingsGeneralEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'General';
	@override String get appearance => 'Appearance';
	@override String get appearanceDesc => 'Configure app theme and refresh rate';
	@override String get language => 'App Language';
	@override String get languageDesc => 'Choose the display language for the app interface';
	@override String get followSystem => 'Follow System';
	@override String get exitBehavior => 'On Close';
	@override String get exitApp => 'Exit Kazumi';
	@override String get minimizeToTray => 'Minimize to Tray';
	@override String get askEveryTime => 'Ask Every Time';
}

// Path: settings.source
class _TranslationsSettingsSourceEnUs extends _TranslationsSettingsSourceZhCn {
	_TranslationsSettingsSourceEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Source';
	@override String get ruleManagement => 'Rule Management';
	@override String get ruleManagementDesc => 'Manage anime resource rules';
	@override String get githubProxy => 'GitHub Proxy';
	@override String get githubProxyDesc => 'Use proxy to access rule repository';
}

// Path: settings.player
class _TranslationsSettingsPlayerEnUs extends _TranslationsSettingsPlayerZhCn {
	_TranslationsSettingsPlayerEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Player Settings';
	@override String get playerSettings => 'Player Settings';
	@override String get playerSettingsDesc => 'Configure player parameters';
	@override String get danmakuSettings => 'Danmaku Settings';
	@override String get danmakuSettingsDesc => 'Configure danmaku parameters';
}

// Path: settings.webdav
class _TranslationsSettingsWebdavEnUs extends _TranslationsSettingsWebdavZhCn {
	_TranslationsSettingsWebdavEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'WebDAV';
	@override String get desc => 'Configure sync parameters';
}

// Path: settings.other
class _TranslationsSettingsOtherEnUs extends _TranslationsSettingsOtherZhCn {
	_TranslationsSettingsOtherEnUs._(_TranslationsEnUs root) : this._root = root, super._(root);

	@override final _TranslationsEnUs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Other';
	@override String get about => 'About';
}

// Path: <root>
class _TranslationsJaJp extends AppTranslations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsJaJp.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.jaJp,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja-JP>.
	@override final TranslationMetadata<AppLocale, AppTranslations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _TranslationsJaJp _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsAppJaJp app = _TranslationsAppJaJp._(_root);
	@override late final _TranslationsMetadataJaJp metadata = _TranslationsMetadataJaJp._(_root);
	@override late final _TranslationsDownloadsJaJp downloads = _TranslationsDownloadsJaJp._(_root);
	@override late final _TranslationsTorrentJaJp torrent = _TranslationsTorrentJaJp._(_root);
	@override late final _TranslationsSettingsJaJp settings = _TranslationsSettingsJaJp._(_root);
	@override late final _TranslationsExitDialogJaJp exitDialog = _TranslationsExitDialogJaJp._(_root);
	@override late final _TranslationsTrayJaJp tray = _TranslationsTrayJaJp._(_root);
}

// Path: app
class _TranslationsAppJaJp extends _TranslationsAppZhCn {
	_TranslationsAppJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kazumi';
	@override String get loading => '読み込み中…';
	@override String get retry => '再試行';
	@override String get confirm => '確認';
	@override String get cancel => 'キャンセル';
}

// Path: metadata
class _TranslationsMetadataJaJp extends _TranslationsMetadataZhCn {
	_TranslationsMetadataJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => '作品情報';
	@override String get refresh => 'メタデータを更新';
	@override late final _TranslationsMetadataSourceJaJp source = _TranslationsMetadataSourceJaJp._(_root);
	@override String get lastSynced => '最終同期: {timestamp}';
}

// Path: downloads
class _TranslationsDownloadsJaJp extends _TranslationsDownloadsZhCn {
	_TranslationsDownloadsJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'ダウンロードキュー';
	@override String get aria2Offline => 'aria2未接続';
	@override String get queued => '待機中';
	@override String get running => 'ダウンロード中';
	@override String get completed => '完了';
}

// Path: torrent
class _TranslationsTorrentJaJp extends _TranslationsTorrentZhCn {
	_TranslationsTorrentJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTorrentConsentJaJp consent = _TranslationsTorrentConsentJaJp._(_root);
	@override late final _TranslationsTorrentErrorJaJp error = _TranslationsTorrentErrorJaJp._(_root);
}

// Path: settings
class _TranslationsSettingsJaJp extends _TranslationsSettingsZhCn {
	_TranslationsSettingsJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => '設定';
	@override late final _TranslationsSettingsMetadataJaJp metadata = _TranslationsSettingsMetadataJaJp._(_root);
	@override String get downloads => 'ダウンロード設定';
	@override String get playback => '再生設定';
	@override late final _TranslationsSettingsGeneralJaJp general = _TranslationsSettingsGeneralJaJp._(_root);
	@override late final _TranslationsSettingsSourceJaJp source = _TranslationsSettingsSourceJaJp._(_root);
	@override late final _TranslationsSettingsPlayerJaJp player = _TranslationsSettingsPlayerJaJp._(_root);
	@override late final _TranslationsSettingsWebdavJaJp webdav = _TranslationsSettingsWebdavJaJp._(_root);
	@override late final _TranslationsSettingsOtherJaJp other = _TranslationsSettingsOtherJaJp._(_root);
}

// Path: exitDialog
class _TranslationsExitDialogJaJp extends _TranslationsExitDialogZhCn {
	_TranslationsExitDialogJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => '終了確認';
	@override String get message => 'Kazumiを終了しますか？';
	@override String get dontAskAgain => '次回から確認しない';
	@override String get exit => 'Kazumiを終了';
	@override String get minimize => 'トレイに最小化';
	@override String get cancel => 'キャンセル';
}

// Path: tray
class _TranslationsTrayJaJp extends _TranslationsTrayZhCn {
	_TranslationsTrayJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get showWindow => 'ウィンドウを表示';
	@override String get exit => 'Kazumiを終了';
}

// Path: metadata.source
class _TranslationsMetadataSourceJaJp extends _TranslationsMetadataSourceZhCn {
	_TranslationsMetadataSourceJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get bangumi => 'Bangumi';
	@override String get tmdb => 'TMDb';
}

// Path: torrent.consent
class _TranslationsTorrentConsentJaJp extends _TranslationsTorrentConsentZhCn {
	_TranslationsTorrentConsentJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => 'BitTorrent使用に関する注意';
	@override String get description => 'BTダウンロードを有効にする前に、現地の法律を遵守し、リスクを理解していることを確認してください。';
	@override String get agree => '理解しました、続行';
	@override String get decline => '今はしない';
}

// Path: torrent.error
class _TranslationsTorrentErrorJaJp extends _TranslationsTorrentErrorZhCn {
	_TranslationsTorrentErrorJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get submit => 'マグネットリンクを送信できません。後でもう一度お試しください';
}

// Path: settings.metadata
class _TranslationsSettingsMetadataJaJp extends _TranslationsSettingsMetadataZhCn {
	_TranslationsSettingsMetadataJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => 'メタデータ';
	@override String get enableBangumi => 'Bangumiメタデータを有効化';
	@override String get enableBangumiDesc => 'Bangumiからアニメ情報を取得';
	@override String get enableTmdb => 'TMDbメタデータを有効化';
	@override String get enableTmdbDesc => 'TMDbから多言語データを補完';
	@override String get preferredLanguage => '優先言語';
	@override String get preferredLanguageDesc => 'メタデータ同期に使用する言語を設定';
	@override String get followSystemLanguage => 'システム言語に従う';
	@override String get simplifiedChinese => '簡体字中国語 (zh-CN)';
	@override String get traditionalChinese => '繁体字中国語 (zh-TW)';
	@override String get japanese => '日本語 (ja-JP)';
	@override String get english => '英語 (en-US)';
	@override String get custom => 'カスタム';
}

// Path: settings.general
class _TranslationsSettingsGeneralJaJp extends _TranslationsSettingsGeneralZhCn {
	_TranslationsSettingsGeneralJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => '一般';
	@override String get appearance => '外観';
	@override String get appearanceDesc => 'アプリのテーマとリフレッシュレートを設定';
	@override String get language => 'アプリの言語';
	@override String get languageDesc => 'アプリインターフェースの表示言語を選択';
	@override String get followSystem => 'システムに従う';
	@override String get exitBehavior => '終了時';
	@override String get exitApp => 'Kazumiを終了';
	@override String get minimizeToTray => 'トレイに最小化';
	@override String get askEveryTime => '毎回確認する';
}

// Path: settings.source
class _TranslationsSettingsSourceJaJp extends _TranslationsSettingsSourceZhCn {
	_TranslationsSettingsSourceJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => 'ソース';
	@override String get ruleManagement => 'ルール管理';
	@override String get ruleManagementDesc => 'アニメリソースルールを管理';
	@override String get githubProxy => 'GitHubプロキシ';
	@override String get githubProxyDesc => 'プロキシを使用してルールリポジトリにアクセス';
}

// Path: settings.player
class _TranslationsSettingsPlayerJaJp extends _TranslationsSettingsPlayerZhCn {
	_TranslationsSettingsPlayerJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => 'プレーヤー設定';
	@override String get playerSettings => 'プレーヤー設定';
	@override String get playerSettingsDesc => 'プレーヤーパラメータを設定';
	@override String get danmakuSettings => '弾幕設定';
	@override String get danmakuSettingsDesc => '弾幕パラメータを設定';
}

// Path: settings.webdav
class _TranslationsSettingsWebdavJaJp extends _TranslationsSettingsWebdavZhCn {
	_TranslationsSettingsWebdavJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => 'WebDAV';
	@override String get desc => '同期パラメータを設定';
}

// Path: settings.other
class _TranslationsSettingsOtherJaJp extends _TranslationsSettingsOtherZhCn {
	_TranslationsSettingsOtherJaJp._(_TranslationsJaJp root) : this._root = root, super._(root);

	@override final _TranslationsJaJp _root; // ignore: unused_field

	// Translations
	@override String get title => 'その他';
	@override String get about => 'について';
}

// Path: <root>
class _TranslationsZhTw extends AppTranslations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsZhTw.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.zhTw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-TW>.
	@override final TranslationMetadata<AppLocale, AppTranslations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _TranslationsZhTw _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsAppZhTw app = _TranslationsAppZhTw._(_root);
	@override late final _TranslationsMetadataZhTw metadata = _TranslationsMetadataZhTw._(_root);
	@override late final _TranslationsDownloadsZhTw downloads = _TranslationsDownloadsZhTw._(_root);
	@override late final _TranslationsTorrentZhTw torrent = _TranslationsTorrentZhTw._(_root);
	@override late final _TranslationsSettingsZhTw settings = _TranslationsSettingsZhTw._(_root);
	@override late final _TranslationsExitDialogZhTw exitDialog = _TranslationsExitDialogZhTw._(_root);
	@override late final _TranslationsTrayZhTw tray = _TranslationsTrayZhTw._(_root);
}

// Path: app
class _TranslationsAppZhTw extends _TranslationsAppZhCn {
	_TranslationsAppZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kazumi';
	@override String get loading => '載入中…';
	@override String get retry => '重試';
	@override String get confirm => '確認';
	@override String get cancel => '取消';
}

// Path: metadata
class _TranslationsMetadataZhTw extends _TranslationsMetadataZhCn {
	_TranslationsMetadataZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => '作品資訊';
	@override String get refresh => '重新整理中繼資料';
	@override late final _TranslationsMetadataSourceZhTw source = _TranslationsMetadataSourceZhTw._(_root);
	@override String get lastSynced => '上次同步：{timestamp}';
}

// Path: downloads
class _TranslationsDownloadsZhTw extends _TranslationsDownloadsZhCn {
	_TranslationsDownloadsZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => '下載佇列';
	@override String get aria2Offline => 'aria2 未連線';
	@override String get queued => '排隊中';
	@override String get running => '下載中';
	@override String get completed => '已完成';
}

// Path: torrent
class _TranslationsTorrentZhTw extends _TranslationsTorrentZhCn {
	_TranslationsTorrentZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTorrentConsentZhTw consent = _TranslationsTorrentConsentZhTw._(_root);
	@override late final _TranslationsTorrentErrorZhTw error = _TranslationsTorrentErrorZhTw._(_root);
}

// Path: settings
class _TranslationsSettingsZhTw extends _TranslationsSettingsZhCn {
	_TranslationsSettingsZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '設定';
	@override late final _TranslationsSettingsMetadataZhTw metadata = _TranslationsSettingsMetadataZhTw._(_root);
	@override String get downloads => '下載設定';
	@override String get playback => '播放偏好';
	@override late final _TranslationsSettingsGeneralZhTw general = _TranslationsSettingsGeneralZhTw._(_root);
	@override late final _TranslationsSettingsSourceZhTw source = _TranslationsSettingsSourceZhTw._(_root);
	@override late final _TranslationsSettingsPlayerZhTw player = _TranslationsSettingsPlayerZhTw._(_root);
	@override late final _TranslationsSettingsWebdavZhTw webdav = _TranslationsSettingsWebdavZhTw._(_root);
	@override late final _TranslationsSettingsOtherZhTw other = _TranslationsSettingsOtherZhTw._(_root);
}

// Path: exitDialog
class _TranslationsExitDialogZhTw extends _TranslationsExitDialogZhCn {
	_TranslationsExitDialogZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '結束確認';
	@override String get message => '您想要結束 Kazumi 嗎？';
	@override String get dontAskAgain => '下次不再詢問';
	@override String get exit => '結束 Kazumi';
	@override String get minimize => '最小化至系統匣';
	@override String get cancel => '取消';
}

// Path: tray
class _TranslationsTrayZhTw extends _TranslationsTrayZhCn {
	_TranslationsTrayZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get showWindow => '顯示視窗';
	@override String get exit => '結束 Kazumi';
}

// Path: metadata.source
class _TranslationsMetadataSourceZhTw extends _TranslationsMetadataSourceZhCn {
	_TranslationsMetadataSourceZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get bangumi => 'Bangumi';
	@override String get tmdb => 'TMDb';
}

// Path: torrent.consent
class _TranslationsTorrentConsentZhTw extends _TranslationsTorrentConsentZhCn {
	_TranslationsTorrentConsentZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => 'BitTorrent 使用提示';
	@override String get description => '啟用 BT 下載前，請確認遵守所在地法律並瞭解使用風險。';
	@override String get agree => '我已知悉，繼續';
	@override String get decline => '暫不開啟';
}

// Path: torrent.error
class _TranslationsTorrentErrorZhTw extends _TranslationsTorrentErrorZhCn {
	_TranslationsTorrentErrorZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get submit => '無法提交磁力連結，稍後重試';
}

// Path: settings.metadata
class _TranslationsSettingsMetadataZhTw extends _TranslationsSettingsMetadataZhCn {
	_TranslationsSettingsMetadataZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '中繼資料';
	@override String get enableBangumi => '啟用 Bangumi 中繼資料';
	@override String get enableBangumiDesc => '從 Bangumi 拉取番劇資訊';
	@override String get enableTmdb => '啟用 TMDb 中繼資料';
	@override String get enableTmdbDesc => '從 TMDb 補充多語言資料';
	@override String get preferredLanguage => '優先語言';
	@override String get preferredLanguageDesc => '設定中繼資料同步時使用的語言';
	@override String get followSystemLanguage => '跟隨系統語言';
	@override String get simplifiedChinese => '簡體中文 (zh-CN)';
	@override String get traditionalChinese => '繁體中文 (zh-TW)';
	@override String get japanese => '日語 (ja-JP)';
	@override String get english => '英語 (en-US)';
	@override String get custom => '自訂';
}

// Path: settings.general
class _TranslationsSettingsGeneralZhTw extends _TranslationsSettingsGeneralZhCn {
	_TranslationsSettingsGeneralZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '一般';
	@override String get appearance => '外觀設定';
	@override String get appearanceDesc => '設定應用程式主題和更新率';
	@override String get language => '應用程式語言';
	@override String get languageDesc => '選擇應用程式介面顯示語言';
	@override String get followSystem => '跟隨系統';
	@override String get exitBehavior => '關閉時';
	@override String get exitApp => '結束 Kazumi';
	@override String get minimizeToTray => '最小化至系統匣';
	@override String get askEveryTime => '每次都詢問';
}

// Path: settings.source
class _TranslationsSettingsSourceZhTw extends _TranslationsSettingsSourceZhCn {
	_TranslationsSettingsSourceZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '來源';
	@override String get ruleManagement => '規則管理';
	@override String get ruleManagementDesc => '管理番劇資源規則';
	@override String get githubProxy => 'Github 映象';
	@override String get githubProxyDesc => '使用映象存取規則託管儲存庫';
}

// Path: settings.player
class _TranslationsSettingsPlayerZhTw extends _TranslationsSettingsPlayerZhCn {
	_TranslationsSettingsPlayerZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '播放器設定';
	@override String get playerSettings => '播放設定';
	@override String get playerSettingsDesc => '設定播放器相關參數';
	@override String get danmakuSettings => '彈幕設定';
	@override String get danmakuSettingsDesc => '設定彈幕相關參數';
}

// Path: settings.webdav
class _TranslationsSettingsWebdavZhTw extends _TranslationsSettingsWebdavZhCn {
	_TranslationsSettingsWebdavZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => 'WebDAV';
	@override String get desc => '設定同步參數';
}

// Path: settings.other
class _TranslationsSettingsOtherZhTw extends _TranslationsSettingsOtherZhCn {
	_TranslationsSettingsOtherZhTw._(_TranslationsZhTw root) : this._root = root, super._(root);

	@override final _TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '其他';
	@override String get about => '關於';
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
			case 'settings.title': return '设置';
			case 'settings.metadata.title': return '元数据';
			case 'settings.metadata.enableBangumi': return '启用 Bangumi 元数据';
			case 'settings.metadata.enableBangumiDesc': return '从 Bangumi 拉取番剧信息';
			case 'settings.metadata.enableTmdb': return '启用 TMDb 元数据';
			case 'settings.metadata.enableTmdbDesc': return '从 TMDb 补充多语言资料';
			case 'settings.metadata.preferredLanguage': return '优先语言';
			case 'settings.metadata.preferredLanguageDesc': return '设置元数据同步时使用的语言';
			case 'settings.metadata.followSystemLanguage': return '跟随系统语言';
			case 'settings.metadata.simplifiedChinese': return '简体中文 (zh-CN)';
			case 'settings.metadata.traditionalChinese': return '繁體中文 (zh-TW)';
			case 'settings.metadata.japanese': return '日语 (ja-JP)';
			case 'settings.metadata.english': return '英语 (en-US)';
			case 'settings.metadata.custom': return '自定义';
			case 'settings.downloads': return '下载设置';
			case 'settings.playback': return '播放偏好';
			case 'settings.general.title': return '通用';
			case 'settings.general.appearance': return '外观设置';
			case 'settings.general.appearanceDesc': return '设置应用主题和刷新率';
			case 'settings.general.language': return '应用语言';
			case 'settings.general.languageDesc': return '选择应用界面显示语言';
			case 'settings.general.followSystem': return '跟随系统';
			case 'settings.general.exitBehavior': return '关闭时';
			case 'settings.general.exitApp': return '退出 Kazumi';
			case 'settings.general.minimizeToTray': return '最小化至托盘';
			case 'settings.general.askEveryTime': return '每次都询问';
			case 'settings.source.title': return '源';
			case 'settings.source.ruleManagement': return '规则管理';
			case 'settings.source.ruleManagementDesc': return '管理番剧资源规则';
			case 'settings.source.githubProxy': return 'Github 镜像';
			case 'settings.source.githubProxyDesc': return '使用镜像访问规则托管仓库';
			case 'settings.player.title': return '播放器设置';
			case 'settings.player.playerSettings': return '播放设置';
			case 'settings.player.playerSettingsDesc': return '设置播放器相关参数';
			case 'settings.player.danmakuSettings': return '弹幕设置';
			case 'settings.player.danmakuSettingsDesc': return '设置弹幕相关参数';
			case 'settings.webdav.title': return 'WebDAV';
			case 'settings.webdav.desc': return '设置同步参数';
			case 'settings.other.title': return '其他';
			case 'settings.other.about': return '关于';
			case 'exitDialog.title': return '退出确认';
			case 'exitDialog.message': return '您想要退出 Kazumi 吗？';
			case 'exitDialog.dontAskAgain': return '下次不再询问';
			case 'exitDialog.exit': return '退出 Kazumi';
			case 'exitDialog.minimize': return '最小化至托盘';
			case 'exitDialog.cancel': return '取消';
			case 'tray.showWindow': return '显示窗口';
			case 'tray.exit': return '退出 Kazumi';
			default: return null;
		}
	}
}

extension on _TranslationsEnUs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'Kazumi';
			case 'app.loading': return 'Loading…';
			case 'app.retry': return 'Retry';
			case 'app.confirm': return 'Confirm';
			case 'app.cancel': return 'Cancel';
			case 'metadata.sectionTitle': return 'Media Information';
			case 'metadata.refresh': return 'Refresh Metadata';
			case 'metadata.source.bangumi': return 'Bangumi';
			case 'metadata.source.tmdb': return 'TMDb';
			case 'metadata.lastSynced': return 'Last synced: {timestamp}';
			case 'downloads.sectionTitle': return 'Download Queue';
			case 'downloads.aria2Offline': return 'aria2 not connected';
			case 'downloads.queued': return 'Queued';
			case 'downloads.running': return 'Downloading';
			case 'downloads.completed': return 'Completed';
			case 'torrent.consent.title': return 'BitTorrent Usage Notice';
			case 'torrent.consent.description': return 'Before enabling BT downloads, please confirm compliance with local laws and understand the risks involved.';
			case 'torrent.consent.agree': return 'I understand, continue';
			case 'torrent.consent.decline': return 'Not now';
			case 'torrent.error.submit': return 'Unable to submit magnet link, please try again later';
			case 'settings.title': return 'Settings';
			case 'settings.metadata.title': return 'Metadata';
			case 'settings.metadata.enableBangumi': return 'Enable Bangumi Metadata';
			case 'settings.metadata.enableBangumiDesc': return 'Fetch anime information from Bangumi';
			case 'settings.metadata.enableTmdb': return 'Enable TMDb Metadata';
			case 'settings.metadata.enableTmdbDesc': return 'Supplement multilingual data from TMDb';
			case 'settings.metadata.preferredLanguage': return 'Preferred Language';
			case 'settings.metadata.preferredLanguageDesc': return 'Set the language for metadata synchronization';
			case 'settings.metadata.followSystemLanguage': return 'Follow System Language';
			case 'settings.metadata.simplifiedChinese': return 'Simplified Chinese (zh-CN)';
			case 'settings.metadata.traditionalChinese': return 'Traditional Chinese (zh-TW)';
			case 'settings.metadata.japanese': return 'Japanese (ja-JP)';
			case 'settings.metadata.english': return 'English (en-US)';
			case 'settings.metadata.custom': return 'Custom';
			case 'settings.downloads': return 'Download Settings';
			case 'settings.playback': return 'Playback Preferences';
			case 'settings.general.title': return 'General';
			case 'settings.general.appearance': return 'Appearance';
			case 'settings.general.appearanceDesc': return 'Configure app theme and refresh rate';
			case 'settings.general.language': return 'App Language';
			case 'settings.general.languageDesc': return 'Choose the display language for the app interface';
			case 'settings.general.followSystem': return 'Follow System';
			case 'settings.general.exitBehavior': return 'On Close';
			case 'settings.general.exitApp': return 'Exit Kazumi';
			case 'settings.general.minimizeToTray': return 'Minimize to Tray';
			case 'settings.general.askEveryTime': return 'Ask Every Time';
			case 'settings.source.title': return 'Source';
			case 'settings.source.ruleManagement': return 'Rule Management';
			case 'settings.source.ruleManagementDesc': return 'Manage anime resource rules';
			case 'settings.source.githubProxy': return 'GitHub Proxy';
			case 'settings.source.githubProxyDesc': return 'Use proxy to access rule repository';
			case 'settings.player.title': return 'Player Settings';
			case 'settings.player.playerSettings': return 'Player Settings';
			case 'settings.player.playerSettingsDesc': return 'Configure player parameters';
			case 'settings.player.danmakuSettings': return 'Danmaku Settings';
			case 'settings.player.danmakuSettingsDesc': return 'Configure danmaku parameters';
			case 'settings.webdav.title': return 'WebDAV';
			case 'settings.webdav.desc': return 'Configure sync parameters';
			case 'settings.other.title': return 'Other';
			case 'settings.other.about': return 'About';
			case 'exitDialog.title': return 'Exit Confirmation';
			case 'exitDialog.message': return 'Do you want to exit Kazumi?';
			case 'exitDialog.dontAskAgain': return 'Don\'t ask again';
			case 'exitDialog.exit': return 'Exit Kazumi';
			case 'exitDialog.minimize': return 'Minimize to Tray';
			case 'exitDialog.cancel': return 'Cancel';
			case 'tray.showWindow': return 'Show Window';
			case 'tray.exit': return 'Exit Kazumi';
			default: return null;
		}
	}
}

extension on _TranslationsJaJp {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'Kazumi';
			case 'app.loading': return '読み込み中…';
			case 'app.retry': return '再試行';
			case 'app.confirm': return '確認';
			case 'app.cancel': return 'キャンセル';
			case 'metadata.sectionTitle': return '作品情報';
			case 'metadata.refresh': return 'メタデータを更新';
			case 'metadata.source.bangumi': return 'Bangumi';
			case 'metadata.source.tmdb': return 'TMDb';
			case 'metadata.lastSynced': return '最終同期: {timestamp}';
			case 'downloads.sectionTitle': return 'ダウンロードキュー';
			case 'downloads.aria2Offline': return 'aria2未接続';
			case 'downloads.queued': return '待機中';
			case 'downloads.running': return 'ダウンロード中';
			case 'downloads.completed': return '完了';
			case 'torrent.consent.title': return 'BitTorrent使用に関する注意';
			case 'torrent.consent.description': return 'BTダウンロードを有効にする前に、現地の法律を遵守し、リスクを理解していることを確認してください。';
			case 'torrent.consent.agree': return '理解しました、続行';
			case 'torrent.consent.decline': return '今はしない';
			case 'torrent.error.submit': return 'マグネットリンクを送信できません。後でもう一度お試しください';
			case 'settings.title': return '設定';
			case 'settings.metadata.title': return 'メタデータ';
			case 'settings.metadata.enableBangumi': return 'Bangumiメタデータを有効化';
			case 'settings.metadata.enableBangumiDesc': return 'Bangumiからアニメ情報を取得';
			case 'settings.metadata.enableTmdb': return 'TMDbメタデータを有効化';
			case 'settings.metadata.enableTmdbDesc': return 'TMDbから多言語データを補完';
			case 'settings.metadata.preferredLanguage': return '優先言語';
			case 'settings.metadata.preferredLanguageDesc': return 'メタデータ同期に使用する言語を設定';
			case 'settings.metadata.followSystemLanguage': return 'システム言語に従う';
			case 'settings.metadata.simplifiedChinese': return '簡体字中国語 (zh-CN)';
			case 'settings.metadata.traditionalChinese': return '繁体字中国語 (zh-TW)';
			case 'settings.metadata.japanese': return '日本語 (ja-JP)';
			case 'settings.metadata.english': return '英語 (en-US)';
			case 'settings.metadata.custom': return 'カスタム';
			case 'settings.downloads': return 'ダウンロード設定';
			case 'settings.playback': return '再生設定';
			case 'settings.general.title': return '一般';
			case 'settings.general.appearance': return '外観';
			case 'settings.general.appearanceDesc': return 'アプリのテーマとリフレッシュレートを設定';
			case 'settings.general.language': return 'アプリの言語';
			case 'settings.general.languageDesc': return 'アプリインターフェースの表示言語を選択';
			case 'settings.general.followSystem': return 'システムに従う';
			case 'settings.general.exitBehavior': return '終了時';
			case 'settings.general.exitApp': return 'Kazumiを終了';
			case 'settings.general.minimizeToTray': return 'トレイに最小化';
			case 'settings.general.askEveryTime': return '毎回確認する';
			case 'settings.source.title': return 'ソース';
			case 'settings.source.ruleManagement': return 'ルール管理';
			case 'settings.source.ruleManagementDesc': return 'アニメリソースルールを管理';
			case 'settings.source.githubProxy': return 'GitHubプロキシ';
			case 'settings.source.githubProxyDesc': return 'プロキシを使用してルールリポジトリにアクセス';
			case 'settings.player.title': return 'プレーヤー設定';
			case 'settings.player.playerSettings': return 'プレーヤー設定';
			case 'settings.player.playerSettingsDesc': return 'プレーヤーパラメータを設定';
			case 'settings.player.danmakuSettings': return '弾幕設定';
			case 'settings.player.danmakuSettingsDesc': return '弾幕パラメータを設定';
			case 'settings.webdav.title': return 'WebDAV';
			case 'settings.webdav.desc': return '同期パラメータを設定';
			case 'settings.other.title': return 'その他';
			case 'settings.other.about': return 'について';
			case 'exitDialog.title': return '終了確認';
			case 'exitDialog.message': return 'Kazumiを終了しますか？';
			case 'exitDialog.dontAskAgain': return '次回から確認しない';
			case 'exitDialog.exit': return 'Kazumiを終了';
			case 'exitDialog.minimize': return 'トレイに最小化';
			case 'exitDialog.cancel': return 'キャンセル';
			case 'tray.showWindow': return 'ウィンドウを表示';
			case 'tray.exit': return 'Kazumiを終了';
			default: return null;
		}
	}
}

extension on _TranslationsZhTw {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'Kazumi';
			case 'app.loading': return '載入中…';
			case 'app.retry': return '重試';
			case 'app.confirm': return '確認';
			case 'app.cancel': return '取消';
			case 'metadata.sectionTitle': return '作品資訊';
			case 'metadata.refresh': return '重新整理中繼資料';
			case 'metadata.source.bangumi': return 'Bangumi';
			case 'metadata.source.tmdb': return 'TMDb';
			case 'metadata.lastSynced': return '上次同步：{timestamp}';
			case 'downloads.sectionTitle': return '下載佇列';
			case 'downloads.aria2Offline': return 'aria2 未連線';
			case 'downloads.queued': return '排隊中';
			case 'downloads.running': return '下載中';
			case 'downloads.completed': return '已完成';
			case 'torrent.consent.title': return 'BitTorrent 使用提示';
			case 'torrent.consent.description': return '啟用 BT 下載前，請確認遵守所在地法律並瞭解使用風險。';
			case 'torrent.consent.agree': return '我已知悉，繼續';
			case 'torrent.consent.decline': return '暫不開啟';
			case 'torrent.error.submit': return '無法提交磁力連結，稍後重試';
			case 'settings.title': return '設定';
			case 'settings.metadata.title': return '中繼資料';
			case 'settings.metadata.enableBangumi': return '啟用 Bangumi 中繼資料';
			case 'settings.metadata.enableBangumiDesc': return '從 Bangumi 拉取番劇資訊';
			case 'settings.metadata.enableTmdb': return '啟用 TMDb 中繼資料';
			case 'settings.metadata.enableTmdbDesc': return '從 TMDb 補充多語言資料';
			case 'settings.metadata.preferredLanguage': return '優先語言';
			case 'settings.metadata.preferredLanguageDesc': return '設定中繼資料同步時使用的語言';
			case 'settings.metadata.followSystemLanguage': return '跟隨系統語言';
			case 'settings.metadata.simplifiedChinese': return '簡體中文 (zh-CN)';
			case 'settings.metadata.traditionalChinese': return '繁體中文 (zh-TW)';
			case 'settings.metadata.japanese': return '日語 (ja-JP)';
			case 'settings.metadata.english': return '英語 (en-US)';
			case 'settings.metadata.custom': return '自訂';
			case 'settings.downloads': return '下載設定';
			case 'settings.playback': return '播放偏好';
			case 'settings.general.title': return '一般';
			case 'settings.general.appearance': return '外觀設定';
			case 'settings.general.appearanceDesc': return '設定應用程式主題和更新率';
			case 'settings.general.language': return '應用程式語言';
			case 'settings.general.languageDesc': return '選擇應用程式介面顯示語言';
			case 'settings.general.followSystem': return '跟隨系統';
			case 'settings.general.exitBehavior': return '關閉時';
			case 'settings.general.exitApp': return '結束 Kazumi';
			case 'settings.general.minimizeToTray': return '最小化至系統匣';
			case 'settings.general.askEveryTime': return '每次都詢問';
			case 'settings.source.title': return '來源';
			case 'settings.source.ruleManagement': return '規則管理';
			case 'settings.source.ruleManagementDesc': return '管理番劇資源規則';
			case 'settings.source.githubProxy': return 'Github 映象';
			case 'settings.source.githubProxyDesc': return '使用映象存取規則託管儲存庫';
			case 'settings.player.title': return '播放器設定';
			case 'settings.player.playerSettings': return '播放設定';
			case 'settings.player.playerSettingsDesc': return '設定播放器相關參數';
			case 'settings.player.danmakuSettings': return '彈幕設定';
			case 'settings.player.danmakuSettingsDesc': return '設定彈幕相關參數';
			case 'settings.webdav.title': return 'WebDAV';
			case 'settings.webdav.desc': return '設定同步參數';
			case 'settings.other.title': return '其他';
			case 'settings.other.about': return '關於';
			case 'exitDialog.title': return '結束確認';
			case 'exitDialog.message': return '您想要結束 Kazumi 嗎？';
			case 'exitDialog.dontAskAgain': return '下次不再詢問';
			case 'exitDialog.exit': return '結束 Kazumi';
			case 'exitDialog.minimize': return '最小化至系統匣';
			case 'exitDialog.cancel': return '取消';
			case 'tray.showWindow': return '顯示視窗';
			case 'tray.exit': return '結束 Kazumi';
			default: return null;
		}
	}
}
