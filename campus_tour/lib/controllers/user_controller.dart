import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;

  var userModel = Rxn<UserModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 💡 核心修正：主動監聽 Firebase 登入狀態的變化
    // 只要 Auth 狀態一改變 (登入、登出、啟動初始化完成)，就會自動執行 fetchCurrentUser
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint("[UserController] 偵測到使用者登入: ${user.uid}");
        fetchCurrentUser();
      } else {
        debugPrint("[UserController] 目前為登出狀態");
        userModel.value = null;
      }
    });
  }

  Future<void> fetchCurrentUser() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final data = await _firestoreService.getUser(user.uid);
        if (data != null) {
          userModel.value = data;
          debugPrint("[UserController] 成功從 Firestore 載入頭像: ${data.photoUrl}");
        }
      }
    } catch (e) {
      debugPrint("[UserController] 抓取錯誤: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(String nickname, String? photoUrl) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.updateUser(uid, {
        'nickname': nickname,
        'photoUrl': photoUrl,
      });
      userModel.value = userModel.value?.copyWith(
        nickname: nickname,
        photoUrl: photoUrl,
      );
    }
  }
}
