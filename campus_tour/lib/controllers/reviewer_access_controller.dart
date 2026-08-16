import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Reads the server-issued Firebase custom claim used for App Review access.
/// No email address or password is trusted by the client.
class ReviewerAccessController extends GetxController {
  final RxBool isReviewer = false.obs;
  final RxBool isLoading = true.obs;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) => unawaited(refreshAccess(user: user)),
    );
  }

  Future<void> refreshAccess({User? user}) async {
    isLoading.value = true;
    try {
      final currentUser = user ?? FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        isReviewer.value = false;
        return;
      }

      final token = await currentUser.getIdTokenResult(true);
      isReviewer.value = token.claims?['appReviewer'] == true;
    } catch (_) {
      // Fail closed if the claim cannot be verified.
      isReviewer.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    isReviewer.value = false;
    isLoading.value = false;
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
