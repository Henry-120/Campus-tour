import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/monster_controller.dart';
import 'package:get/get.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final controller = Get.find<MonsterController>();

  Future<User?> login(String email, String password) async {
    final user = await _authService.login(email, password);
    if (user != null) {
      await controller.loadUserCollection(user.uid);
    }
    return user;
  }

  Future<User?> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      final existingUser = await _firestoreService.getUser(user.uid);
      if (existingUser == null) {
        await _firestoreService.setUser(
          UserModel(
            uid: user.uid,
            email: user.email ?? "",
            nickname: user.displayName ?? "冒險者",
          ),
        );
      }
      await controller.loadUserCollection(user.uid);
    }
    return user;
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<User?> register(String email, String password, String nickname) async {
    final user = await _authService.register(email, password);
    if (user != null) {
      await _firestoreService.setUser(
        UserModel(uid: user.uid, email: user.email ?? email, nickname: nickname),
      );
      // 💡 重要修正：註冊後也要載入收藏，否則主畫面會沒資料
      await controller.loadUserCollection(user.uid);
    }
    return user;
  }

  Future<UserModel?> fetchUser(String uid) async {
    return await _firestoreService.getUser(uid);
  }
}
