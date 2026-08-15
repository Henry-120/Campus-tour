import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/monster_controller.dart';
import '../controllers/user_controller.dart';
import '../services/bighead_service.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final monsterController = Get.find<MonsterController>();
  final userController = Get.find<UserController>();

  Future<User?> login(String email, String password) async {
    final user = await _authService.login(email, password);
    if (user == null) return null;

    final refreshedUser = await _authService.reloadCurrentUser() ?? user;

    if (_needsEmailVerification(refreshedUser)) {
      try {
        await _authService.sendEmailVerification();
      } finally {
        await _authService.logout();
      }
      return refreshedUser;
    }

    await monsterController.loadUserCollection(refreshedUser.uid);
    await userController.fetchCurrentUser();
    return refreshedUser;
  }

  Future<User?> signInWithGoogle() async {
    debugPrint("正在啟動 Google 認證...");
    final user = await _authService.signInWithGoogle();

    if (user != null) {
      debugPrint("Google 認證成功: ${user.uid}");
      await _prepareSocialUser(user);
    }
    return user;
  }

  Future<User?> signInWithApple() async {
    try {
      final user = await _authService.signInWithApple();
      if (user != null) {
        await _prepareSocialUser(user);
      }
      return user;
    } catch (e) {
      debugPrint("LoginController.signInWithApple 失敗: $e");
      rethrow;
    }
  }

  Future<void> _prepareSocialUser(User user) async {
    final existingUser = await _firestoreService.getUser(user.uid);
    if (existingUser == null) {
      await _firestoreService.setUser(
        UserModel(
          uid: user.uid,
          email: user.email ?? "",
          nickname: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : "冒險者",
          photoUrl: BigHeadService.generateRandomUrl(),
        ),
      );
    }
    await monsterController.loadUserCollection(user.uid);
    await userController.fetchCurrentUser();
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> logout() async {
    await _authService.logout();
    monsterController.resetForLogout();
    userController.userModel.value = null;
  }

  Future<void> deleteAccount({String? password}) async {
    final user = _authService.currentUser;
    if (user == null) throw StateError('No signed-in user');

    // Reauthenticate before deleting any data so a stale session cannot leave
    // the account present while its Firestore profile has already been erased.
    final appleAuthorizationCode = await _authService
        .reauthenticateForAccountDeletion(password: password);

    await _firestoreService.deleteUserData(user.uid);

    if (appleAuthorizationCode != null && appleAuthorizationCode.isNotEmpty) {
      await _authService.revokeAppleAuthorization(appleAuthorizationCode);
    }

    await _authService.deleteCurrentUser();
    monsterController.resetForLogout();
    userController.userModel.value = null;
  }

  // 一般註冊
  Future<User?> register(String email, String password, String nickname) async {
    final user = await _authService.register(email, password);
    if (user != null) {
      final randomAvatar = BigHeadService.generateRandomUrl();

      await _firestoreService.setUser(
        UserModel(
          uid: user.uid,
          email: user.email ?? email,
          nickname: nickname,
          photoUrl: randomAvatar,
        ),
      );

      try {
        await _authService.sendEmailVerification();
      } finally {
        await _authService.logout();
      }
    }
    return user;
  }

  Future<UserModel?> fetchUser(String uid) async {
    return await _firestoreService.getUser(uid);
  }

  bool _needsEmailVerification(User user) {
    final isEmailPasswordUser = user.providerData.any(
      (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
    );

    return isEmailPasswordUser && !user.emailVerified;
  }
}
