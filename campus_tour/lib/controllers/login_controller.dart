import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<User?> login(String email, String password) async {
    return await _authService.login(email, password);
  }


  Future<void> logout() async {
    await _authService.logout();
  }

  Future<User?> register(String email, String password, String nickname) async {
    final user = await _authService.register(email, password);
    if (user != null) {
      await _firestoreService.saveUser(
        UserModel(uid: user.uid, email: user.email!, nickname: nickname),
      );
    }
    return user;
  }

  Future<UserModel?> fetchUser(String uid) async {
    return await _firestoreService.getUser(uid);
  }
}
