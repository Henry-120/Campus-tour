import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SMS feature never requests direct SMS access', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, isNot(contains('android.permission.SEND_SMS')));
    expect(manifest, isNot(contains('android.permission.READ_SMS')));
    expect(manifest, isNot(contains('android.permission.RECEIVE_SMS')));
  });

  test('iOS SMS uses the user-approved MessageUI composer', () {
    final appDelegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();

    expect(
      appDelegate,
      contains('MFMessageComposeViewController.canSendText()'),
    );
    expect(appDelegate, contains('composer.messageComposeDelegate = self'));
    expect(appDelegate, contains('composer.recipients = [recipient]'));
    expect(appDelegate, contains('composer.body = body'));
    expect(appDelegate, contains('presenter.present(composer'));
  });
}
