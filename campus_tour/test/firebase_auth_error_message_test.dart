import 'package:campus_tour/utils/firebase_auth_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('firebaseAuthErrorMessage', () {
    test('maps invalid credentials to a safe login message', () {
      final error = FirebaseAuthException(code: 'invalid-credential');

      expect(firebaseAuthErrorMessage(error), 'Email 或密碼不正確。');
    });

    test('explains provider conflicts', () {
      final error = FirebaseAuthException(
        code: 'account-exists-with-different-credential',
      );

      expect(
        firebaseAuthErrorMessage(error),
        '這個 Email 已使用其他登入方式，請先使用原本的登入方式。',
      );
    });

    test('maps network errors', () {
      final error = FirebaseAuthException(code: 'network-request-failed');

      expect(firebaseAuthErrorMessage(error), '網路連線失敗，請確認網路後再試。');
    });
  });
}
