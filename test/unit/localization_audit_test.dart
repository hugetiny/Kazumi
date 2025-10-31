import 'package:flutter_test/flutter_test.dart';

import '../../tool/localization_audit.dart' as audit;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('localization audit passes', () async {
    final issues = await audit.runLocalizationAudit();
    expect(issues, isEmpty, reason: issues.join('\n'));
  });
}
