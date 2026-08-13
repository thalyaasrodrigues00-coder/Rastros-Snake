import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rastros_snake/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App carrega menu principal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const RastrosSnakeApp());
    await tester.pump();

    expect(find.text('Rastros Snake'), findsOneWidget);
    expect(find.text('Jogar'), findsOneWidget);
  });
}
