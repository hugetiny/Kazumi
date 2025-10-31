import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazumi/l10n/generated/translations.g.dart';
import 'package:kazumi/pages/menu/menu.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocale(AppLocale.enUs);
  });

  tearDown(() {
    LocaleSettings.setLocale(AppLocale.zhCn);
  });

  testWidgets('navigation labels respond to locale changes', (tester) async {
    const size = Size(400, 800);
    tester.binding.window.physicalSizeTestValue = size;
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        child: TranslationProvider(
          child: const MaterialApp(
            home: ScaffoldMenu(),
          ),
        ),
      ),
    );

    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('My'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    LocaleSettings.setLocale(AppLocale.zhCn);
    await tester.pumpAndSettle();

    expect(find.text('热门番组'), findsOneWidget);
    expect(find.text('时间表'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  });
}
