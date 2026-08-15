import 'package:campus_tour/widgets/login/forgot_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('submits an email and closes without framework errors', (
    tester,
  ) async {
    String? submittedEmail;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                submittedEmail = await showDialog<String>(
                  context: context,
                  builder: (_) => const ForgotPasswordDialog(),
                );
              },
              child: const Text('開啟'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('開啟'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), ' user@example.com ');
    await tester.tap(find.text('寄送重設信'));
    await tester.pumpAndSettle();

    expect(submittedEmail, 'user@example.com');
    expect(find.byType(ForgotPasswordDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the dialog open for an invalid email', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (_) => const ForgotPasswordDialog(),
              ),
              child: const Text('開啟'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('開啟'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'invalid-email');
    await tester.tap(find.text('寄送重設信'));
    await tester.pump();

    expect(find.text('Email 格式不正確'), findsOneWidget);
    expect(find.byType(ForgotPasswordDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
