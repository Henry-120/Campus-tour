import 'package:firebase_auth/firebase_auth.dart';

String firebaseAuthErrorMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return '發生未預期的錯誤，請稍後再試。';
  }

  return switch (error.code) {
    'invalid-email' => 'Email 格式不正確。',
    'missing-password' => '請輸入密碼。',
    'weak-password' => '密碼強度不足，請至少輸入 6 位。',
    'user-not-found' => '找不到這個 Email 的帳號。',
    'wrong-password' || 'invalid-credential' => 'Email 或密碼不正確。',
    'email-already-in-use' => '這個 Email 已經註冊，請直接登入或使用忘記密碼。',
    'account-exists-with-different-credential' =>
      '這個 Email 已使用其他登入方式，請先使用原本的登入方式。',
    'provider-already-linked' => '這個帳號已經可以使用 Email 和密碼登入。',
    'credential-already-in-use' => '這組登入資料已連結到其他帳號。',
    'requires-recent-login' => '為了帳號安全，請重新登入後再試一次。',
    'too-many-requests' => '嘗試次數過多，請稍後再試。',
    'network-request-failed' => '網路連線失敗，請確認網路後再試。',
    'operation-not-allowed' => 'Firebase 尚未啟用這種登入方式。',
    'google-sign-in-cancelled' => '已取消 Google 身分確認。',
    'google-account-mismatch' => '請選擇目前登入的 Google 帳號。',
    _ => error.message ?? '登入驗證失敗，請稍後再試。',
  };
}
