import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../controllers/user_controller.dart';
import '../services/bighead_service.dart'; // 💡 引入隨機頭像服務
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _db.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          debugPrint("Google Sign-In: 初始化新使用者隨機頭像...");
          final nickname = user.displayName ?? "冒險者";
          final email = user.email ?? ""; 
          
          // 💡 統一使用隨機產生的 BigHead SVG 頭像
          final photoUrl = BigHeadService.generateRandomUrl();
          
          final userModel = UserModel(
            uid: user.uid, 
            email: email, 
            nickname: nickname,
            photoUrl: photoUrl,
          );

          await _db.collection('users').doc(user.uid).set(userModel.toMap());

          if (Get.isRegistered<UserController>()) {
            Get.find<UserController>().userModel.value = userModel;
          }
        }
      }
      return user;
    } catch (e) {
      debugPrint("❌ Google Sign-In 發生錯誤：$e");
      return null;
    }
  }
}
