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

  // Apple 登入/註冊。iOS、Android 使用原生 Provider 流程，Web 使用彈出視窗。
  Future<User?> signInWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    final userCredential = kIsWeb
        ? await _auth.signInWithPopup(appleProvider)
        : await _auth.signInWithProvider(appleProvider);
    return userCredential.user;
  }

  bool hasPasswordProvider([User? user]) {
    final target = user ?? _auth.currentUser;
    return target?.providerData.any(
          (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
        ) ??
        false;
  }

  bool hasAppleProvider([User? user]) {
    final target = user ?? _auth.currentUser;
    return target?.providerData.any(
          (provider) => provider.providerId == AppleAuthProvider.PROVIDER_ID,
        ) ??
        false;
  }

  Future<User> linkAppleProvider() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: '目前沒有可連結 Apple 登入的帳號。',
      );
    }
    if (hasAppleProvider(user)) return user;

    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final result = kIsWeb
        ? await user.linkWithPopup(appleProvider)
        : await user.linkWithProvider(appleProvider);
    return result.user ?? user;
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

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
