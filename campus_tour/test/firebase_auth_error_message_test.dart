import 'package:campus_tour/utils/firebase_auth_error_message.dart';
import 'package:campus_tour/l10n/app_translations.dart';
import 'package:campus_tour/utils/account_data_sync_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUpAll(() {
    Get.addTranslations(AppTranslations().keys);
  });

  setUp(() {
    Get.locale = const Locale('zh');
  });

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

    test('explains disabled accounts', () {
      final error = FirebaseAuthException(code: 'user-disabled');

      expect(firebaseAuthErrorMessage(error), '這個帳號已被停用，請聯絡客服或管理員。');
    });

    test('explains expired sessions in the current language', () {
      Get.locale = const Locale('en');
      final error = FirebaseAuthException(code: 'user-token-expired');

      expect(
        firebaseAuthErrorMessage(error),
        'Your sign-in session has expired. Sign in again.',
      );
    });

    test('does not expose raw Firebase messages for unknown codes', () {
      final error = FirebaseAuthException(
        code: 'new-server-code',
        message: 'Sensitive SDK implementation detail',
      );

      expect(firebaseAuthErrorMessage(error), '登入驗證失敗，請稍後再試。');
    });
  });

  group('googleAuthErrorMessage', () {
    test('recognizes native Google cancellation codes', () {
      final error = PlatformException(code: 'sign_in_canceled');

      expect(isGoogleSignInCancellation(error), isTrue);
      expect(googleAuthErrorMessage(error), '已取消 Google 登入。');
    });

    test('maps native Google network failures', () {
      final error = PlatformException(code: 'network_error');

      expect(googleAuthErrorMessage(error), '網路連線失敗，請確認網路後再試。');
    });

    test('explains native Google configuration failures', () {
      final error = PlatformException(
        code: 'sign_in_failed',
        message: 'ApiException: 10',
      );

      expect(googleAuthErrorMessage(error), contains('Google 登入設定不正確'));
    });

    test('distinguishes expired Google state from cancellation', () {
      final error = PlatformException(code: 'sign_in_required');

      expect(isGoogleSignInCancellation(error), isFalse);
      expect(googleAuthErrorMessage(error), contains('重新選擇 Google 帳號'));
    });
  });

  group('appleAuthErrorMessage', () {
    test('recognizes a canceled Apple authorization', () {
      final error = FirebaseAuthException(code: 'canceled');

      expect(isAppleSignInCancellation(error), isTrue);
      expect(appleAuthErrorMessage(error), '已取消 Apple 登入。');
    });

    test('explains provider conflicts', () {
      final error = FirebaseAuthException(
        code: 'account-exists-with-different-credential',
      );

      expect(appleAuthErrorMessage(error), '這個 Email 已使用其他登入方式，請先使用原本的方式登入。');
    });

    test('uses the current app language', () {
      Get.locale = const Locale('ja');
      final error = FirebaseAuthException(code: 'operation-not-allowed');

      expect(appleAuthErrorMessage(error), 'FirebaseでAppleログインが有効になっていません。');
    });

    test('explains an Apple account linked to another Firebase user', () {
      final error = FirebaseAuthException(code: 'credential-already-in-use');

      expect(appleAuthErrorMessage(error), '這個 Apple 帳號已連結到另一個帳號。');
    });
  });

  group('accountDataSyncErrorMessage', () {
    test('separates a successful login from a Firestore permission error', () {
      final error = AccountDataSyncException(
        operation: AccountDataSyncOperation.signIn,
        cause: FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ),
        stackTrace: StackTrace.empty,
      );

      expect(
        accountDataSyncErrorMessage(error),
        '登入驗證已成功，但無法同步帳號資料。目前沒有存取資料的權限，請檢查 Firestore 安全規則。',
      );
    });

    test('uses a registration-specific Firestore message', () {
      Get.locale = const Locale('ja');
      final error = AccountDataSyncException(
        operation: AccountDataSyncOperation.registration,
        cause: FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        ),
        stackTrace: StackTrace.empty,
      );

      expect(accountDataSyncErrorMessage(error), contains('アカウントを作成'));
      expect(accountDataSyncErrorMessage(error), contains('データサービス'));
    });
  });

  group('account message translations', () {
    final translations = AppTranslations().keys;
    final keys = [
      for (var index = 1; index <= 56; index++)
        'utils.firebase.auth.error.message.s${index.toString().padLeft(3, '0')}',
      for (var index = 8; index <= 10; index++)
        'view.login.page.s${index.toString().padLeft(3, '0')}',
      for (var index = 1; index <= 7; index++)
        'widgets.login.forgot.password.dialog.s${index.toString().padLeft(3, '0')}',
    ];

    test(
      'contains every new account message in Chinese, English, and Japanese',
      () {
        for (final locale in ['zh', 'en', 'ja']) {
          for (final key in keys) {
            expect(
              translations[locale]?[key],
              isNotNull,
              reason: '$locale is missing $key',
            );
            expect(
              translations[locale]?[key],
              isNotEmpty,
              reason: '$locale has an empty value for $key',
            );
          }
        }
      },
    );
  });
}
