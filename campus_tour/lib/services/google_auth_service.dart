import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      // 啟動 Google 登入流程
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      // 取得憑證
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 登入
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // 建立 UserModel
        final nickname = user.displayName ?? "未命名";
        final userModel = UserModel(uid: user.uid, email: user.email!, nickname: nickname);

        // 存到 Firestore
        await _db.collection('users').doc(user.uid).set(userModel.toMap());
      }

      return user;
    } catch (e) {
      print("Google 登入失敗：$e");
      return null;
    }
  }
}
