import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/bighead_service.dart';
import 'user_controller.dart';

class ProfileEditController {
  ProfileEditController({
    required this.userController,
    required this.editingUid,
    required UserModel initialUser,
  }) : nameController = TextEditingController(text: initialUser.nickname) {
    previewUrl.value = initialUser.photoUrl;
    debugPrint(
      '[ProfileEditController] Loaded avatar for $editingUid: '
      '${previewUrl.value}',
    );
  }

  final UserController userController;
  final String editingUid;
  final TextEditingController nameController;
  final RxnString previewUrl = RxnString();
  bool _isDisposed = false;

  void dispose() {
    _isDisposed = true;
    nameController.dispose();
    previewUrl.close();
  }

  Future<void> generateRandomAvatar() async {
    final newUrl = BigHeadService.generateRandomUrl();

    try {
      if (previewUrl.value != null && previewUrl.value!.isNotEmpty) {
        final loader = SvgNetworkLoader(previewUrl.value!);
        svg.cache.evict(loader.cacheKey(null));
      }
    } catch (e) {
      debugPrint("Evict cache error: $e");
    }

    previewUrl.value = "";
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_isDisposed) {
      previewUrl.value = newUrl;
    }
  }

  Future<bool> saveProfile() async {
    final newNickname = nameController.text.trim();

    if (newNickname.isEmpty) {
      Get.snackbar(
        'controllers.profile.edit.controller.s002'.tr,
        'controllers.profile.edit.controller.s003'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.brown,
      );
      return false;
    }

    final saved = await userController.updateProfile(
      expectedUid: editingUid,
      nickname: newNickname,
      photoUrl: previewUrl.value,
    );
    if (!saved) {
      Get.snackbar(
        'controllers.profile.edit.controller.s002'.tr,
        'utils.firebase.auth.error.message.s026'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.brown,
      );
      return false;
    }

    debugPrint('[ProfileEdit] Saved changes for $editingUid: $newNickname');
    return true;
  }
}
