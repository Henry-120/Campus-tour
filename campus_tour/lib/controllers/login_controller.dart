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
    if(user != null){

      //初始化user monster collection
      controller.loadUserCollection(user.uid);

      //建立假資料
      // controller.seedUserMonsters(user.uid);
    }
    return await _authService.login(email, password);
  }


  Future<void> logout() async {
    await _authService.logout();
  }

  Future<User?> register(String email, String password, String nickname) async {
    final user = await _authService.register(email, password);
    if (user != null) {
      await _firestoreService.setUser(
        UserModel(uid: user.uid, email: user.email!, nickname: nickname),
      );
    }
    return user;
  }

  Future<UserModel?> fetchUser(String uid) async {
    return await _firestoreService.getUser(uid);
  }
}
