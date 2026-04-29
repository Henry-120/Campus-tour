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
    if (user != null) {
      await monsterController.loadUserCollection(user.uid);
      await userController.fetchCurrentUser();
      await monsterController.seedUserMonsters(user.uid);
    }
    return user;
  }

  Future<User?> signInWithGoogle() async {
    try {
      debugPrint("正在啟動 Google 認證...");
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        debugPrint("Google 認證成功: ${user.uid}");

        // 檢查使用者是否已存在於 Firestore
        final existingUser = await _firestoreService.getUser(user.uid);
        if (existingUser == null) {
          debugPrint("新使用者，正在建立 Firestore 資料...");

          // 💡 強制使用生成的 SVG 頭像，不論 Google 是否有提供照片
          final photoUrl = BigHeadService.generateRandomUrl();

          await _firestoreService.setUser(
            UserModel(
              uid: user.uid,
              email: user.email ?? "",
              nickname: user.displayName ?? "冒險者",
              photoUrl: photoUrl,
            ),
          );
        }

        debugPrint("正在載入使用者收藏與資料...");
        await monsterController.loadUserCollection(user.uid);
        await userController.fetchCurrentUser();
      }
      return user;
    } catch (e) {
      debugPrint("❌ LoginController.signInWithGoogle 失敗: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
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
      await monsterController.loadUserCollection(user.uid);
      await userController.fetchCurrentUser();
    }
    return user;
  }

  Future<UserModel?> fetchUser(String uid) async {
    return await _firestoreService.getUser(uid);
  }
}
