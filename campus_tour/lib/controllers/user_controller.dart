import 'dart:async';

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
  StreamSubscription<User?>? _authSubscription;
  int _latestFetchRequest = 0;

  String? get currentUid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    // 💡 核心修正：主動監聽 Firebase 登入狀態的變化
    // 只要 Auth 狀態一改變 (登入、登出、啟動初始化完成)，就會自動執行 fetchCurrentUser
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      // Never show the previous account while the new account is loading.
      userModel.value = null;
      if (user != null) {
        debugPrint("[UserController] 偵測到使用者登入: ${user.uid}");
        unawaited(_fetchUser(user.uid));
      } else {
        debugPrint("[UserController] 目前為登出狀態");
        _latestFetchRequest++;
        isLoading.value = false;
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchCurrentUser({bool throwOnError = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      _latestFetchRequest++;
      userModel.value = null;
      isLoading.value = false;
      return;
    }

    await _fetchUser(user.uid, throwOnError: throwOnError);
  }

  Future<void> _fetchUser(
    String requestedUid, {
    bool throwOnError = false,
  }) async {
    final requestId = ++_latestFetchRequest;
    try {
      isLoading.value = true;
      final data = await _firestoreService.getUser(requestedUid);

      // Ignore a response that belongs to an account that has signed out or
      // has already been replaced by another account.
      if (_auth.currentUser?.uid != requestedUid) return;

      if (data != null && data.uid == requestedUid) {
        userModel.value = data;
        debugPrint("[UserController] 成功從 Firestore 載入頭像: ${data.photoUrl}");
      } else if (throwOnError) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'The signed-in user document does not exist.',
        );
      }
    } catch (e) {
      if (_auth.currentUser?.uid != requestedUid) return;
      debugPrint("[UserController] 抓取錯誤: $e");
      if (throwOnError) rethrow;
    } finally {
      if (requestId == _latestFetchRequest) {
        isLoading.value = false;
      }
    }
  }

  Future<bool> updateProfile({
    required String expectedUid,
    required String nickname,
    required String? photoUrl,
  }) async {
    if (_auth.currentUser?.uid != expectedUid ||
        userModel.value?.uid != expectedUid) {
      return false;
    }

    await _firestoreService.updateUser(expectedUid, {
      'nickname': nickname,
      'photoUrl': photoUrl,
    });

    final latestUser = userModel.value;
    if (_auth.currentUser?.uid != expectedUid ||
        latestUser?.uid != expectedUid) {
      return false;
    }

    userModel.value = latestUser?.copyWith(
      nickname: nickname,
      photoUrl: photoUrl,
    );
    return true;
  }
}
