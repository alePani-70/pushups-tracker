import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushups_tracker/presentation/widgets/rep_counter.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)));

  testWidgets('RepCounter counts taps, undoes, and reports the final count', (tester) async {
    int? finished;
    await tester.pumpWidget(wrap(RepCounter(
      title: 'Test',
      instruction: 'Tap away',
      onFinish: (n) => finished = n,
    )));

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('TAP TO COUNT'));
    await tester.tap(find.text('TAP TO COUNT'));
    await tester.tap(find.text('TAP TO COUNT'));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('FINISH TEST'));
    expect(finished, 2);
  });

  testWidgets('UNDO is disabled at zero', (tester) async {
    await tester.pumpWidget(wrap(RepCounter(title: 'T', instruction: 'I', onFinish: (_) {})));
    final undo = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'UNDO'));
    expect(undo.onPressed, isNull);
  });
}
