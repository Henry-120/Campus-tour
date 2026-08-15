import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/monster_controller.dart';
import '../controllers/user_controller.dart';
import '../services/bighead_service.dart';
import '../utils/account_data_sync_exception.dart';
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

    await _loadSignedInUserData(refreshedUser.uid);
    return refreshedUser;
  }

  Future<User?> signInWithGoogle() async {
    debugPrint("正在啟動 Google 認證...");
    final user = await _authService.signInWithGoogle();

    return _completeSocialSignIn(user, providerName: 'Google');
  }

  Future<User?> signInWithApple() async {
    debugPrint('正在啟動 Apple 認證...');
    final user = await _authService.signInWithApple();

    return _completeSocialSignIn(user, providerName: 'Apple');
  }

  Future<User?> _completeSocialSignIn(
    User? user, {
    required String providerName,
  }) async {
    if (user == null) return null;

    debugPrint('$providerName 認證成功: ${user.uid}');

    try {
      // 所有社群登入都用 Firebase UID 找資料，避免 Apple 隱藏 Email 時
      // 因 privaterelay.appleid.com 信箱而誤建或誤合併其他帳號。
      final existingUser = await _firestoreService.getUser(user.uid);
      if (existingUser == null) {
        debugPrint('新使用者，正在建立 Firestore 資料...');

        final photoUrl = BigHeadService.generateRandomUrl();
        final displayName = user.displayName?.trim();

        await _firestoreService.setUser(
          UserModel(
            uid: user.uid,
            email: user.email ?? '',
            nickname: displayName == null || displayName.isEmpty
                ? 'controllers.login.controller.s004'.tr
                : displayName,
            photoUrl: photoUrl,
          ),
        );
      }

      debugPrint('正在載入使用者收藏與資料...');
      await monsterController.loadUserCollection(user.uid);
      await userController.fetchCurrentUser(throwOnError: true);
    } catch (error, stackTrace) {
      throw AccountDataSyncException(
        operation: AccountDataSyncOperation.signIn,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    return user;
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

    // 先重新驗證，避免過期登入狀態造成帳號仍存在、資料卻已刪除。
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
      AccountDataSyncException? syncError;

      try {
        await _firestoreService.setUser(
          UserModel(
            uid: user.uid,
            email: user.email ?? email,
            nickname: nickname,
            photoUrl: randomAvatar,
          ),
        );
      } catch (error, stackTrace) {
        syncError = AccountDataSyncException(
          operation: AccountDataSyncOperation.registration,
          cause: error,
          stackTrace: stackTrace,
        );
      }

      try {
        await _authService.sendEmailVerification();
      } finally {
        await _authService.logout();
      }

      if (syncError != null) {
        Error.throwWithStackTrace(syncError, syncError.stackTrace);
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

  Future<void> _loadSignedInUserData(String uid) async {
    try {
      await monsterController.loadUserCollection(uid);
      await userController.fetchCurrentUser(throwOnError: true);
    } catch (error, stackTrace) {
      throw AccountDataSyncException(
        operation: AccountDataSyncOperation.signIn,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
