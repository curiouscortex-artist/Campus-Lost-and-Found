import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/qr_scanner_screen.dart';
import 'package:flutter_application_1/services/app_state.dart';

void main() {
  testWidgets('login opens the item dashboard', (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const CampusLostFoundApp(),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'alex@student.edu');
    await tester.enterText(find.byType(TextFormField).at(1), 'Student123!');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Alex Johnson'), findsOneWidget);
    expect(find.text('MacBook Pro M2 Silver'), findsOneWidget);
  });

  testWidgets('dashboard fits a narrow mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState()..login('alex@student.edu', 'Student123!');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const CampusLostFoundApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hello, Alex Johnson'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scanner offers manual entry on unsupported desktop platforms',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(home: QrScannerScreen()),
      ),
    );

    expect(
      find.textContaining('Camera scanning is not available'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
