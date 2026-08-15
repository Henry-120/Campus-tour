//專門處理登入、註冊、登出
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint("[AuthService] 登入失敗: $e");
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint("[AuthService] 註冊失敗: $e");
      return null;
    }
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
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // 使用者取消登入

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("[AuthService] Google 登入失敗: $e");
      return null;
    }
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
