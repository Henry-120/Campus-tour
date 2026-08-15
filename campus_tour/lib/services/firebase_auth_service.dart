//專門處理登入、註冊、登出
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null || user.emailVerified) return;

    await user.sendEmailVerification();
  }

  Future<User?> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    await user.reload();
    return _auth.currentUser;
  }

  // Google 登入/註冊
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final credential = await _googleCredential(googleUser);
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  bool hasPasswordProvider([User? user]) {
    final target = user ?? _auth.currentUser;
    return target?.providerData.any(
          (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
        ) ??
        false;
  }

  Future<User> linkEmailPassword(String password) async {
    var user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: '目前沒有可連結密碼的登入帳號。',
      );
    }
    if (hasPasswordProvider(user)) {
      throw FirebaseAuthException(
        code: 'provider-already-linked',
        message: '這個帳號已經可以使用 Email 和密碼登入。',
      );
    }

    final passwordCredential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    try {
      final result = await user.linkWithCredential(passwordCredential);
      return result.user ?? user;
    } on FirebaseAuthException catch (error) {
      if (error.code != 'requires-recent-login') rethrow;

      await _reauthenticateWithGoogle(user);
      user = _auth.currentUser ?? user;
      final result = await user.linkWithCredential(passwordCredential);
      return result.user ?? user;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<AuthCredential> _googleCredential(
    GoogleSignInAccount googleUser,
  ) async {
    final googleAuth = await googleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<void> _reauthenticateWithGoogle(User user) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: '已取消 Google 身分確認。',
      );
    }
    if (googleUser.email.toLowerCase() != user.email?.toLowerCase()) {
      throw FirebaseAuthException(
        code: 'google-account-mismatch',
        message: '請選擇目前登入的 Google 帳號。',
      );
    }

    final credential = await _googleCredential(googleUser);
    await user.reauthenticateWithCredential(credential);
  }

  // Apple 登入（iOS 會使用原生 Apple 登入畫面）。
  Future<User?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final userCredential = await _auth.signInWithProvider(appleProvider);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // 使用者關閉 Apple 登入視窗不視為程式錯誤。
      if (e.code == 'web-context-cancelled' ||
          e.code == 'canceled' ||
          e.code == 'cancelled-popup-request') {
        return null;
      }
      debugPrint("[AuthService] Apple 登入失敗: ${e.code} ${e.message}");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Reauthenticates using the account's existing provider. Returns an Apple
  /// authorization code when one is available so it can be revoked on delete.
  Future<String?> reauthenticateForAccountDeletion({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user');

    final providerIds = user.providerData
        .map((info) => info.providerId)
        .toSet();

    if (providerIds.contains(AppleAuthProvider.PROVIDER_ID)) {
      final provider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final credential = await user.reauthenticateWithProvider(provider);
      return credential.additionalUserInfo?.authorizationCode;
    }

    if (providerIds.contains(GoogleAuthProvider.PROVIDER_ID)) {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw StateError('Reauthentication cancelled');
      final googleAuth = await googleUser.authentication;
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );
      return null;
    }

    final email = user.email;
    if (email == null || password == null || password.isEmpty) {
      throw StateError('Password required');
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
    return null;
  }

  Future<void> revokeAppleAuthorization(String authorizationCode) async {
    await _auth.revokeTokenWithAuthorizationCode(authorizationCode);
  }

  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user');
    await user.delete();
    await _googleSignIn.signOut();
  }
}
