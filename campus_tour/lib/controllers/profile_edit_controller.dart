import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../services/bighead_service.dart';
import 'user_controller.dart';

class ProfileEditController extends GetxController {
  final UserController userController = Get.find<UserController>();
  
  late TextEditingController nameController;
  final RxnString previewUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    // 💡 修正：初始化時將目前的暱稱帶入輸入框，讓使用者可以直接修改
    final currentNickname = userController.userModel.value?.nickname ?? "";
    nameController = TextEditingController(text: currentNickname);
    
    previewUrl.value = userController.userModel.value?.photoUrl;
    debugPrint("[profile_edit_controller] 成功載入頭像: ${previewUrl.value}");
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
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
    
    previewUrl.value = newUrl;
  }

  Future<void> saveProfile() async {
    final newNickname = nameController.text.trim();
    
    // 💡 增加防呆：暱稱不可為空
    if (newNickname.isEmpty) {
      Get.snackbar(
        "小提示", 
        "暱稱不能空著喔！",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.brown,
      );
      return;
    }
        
    debugPrint("[ProfileEdit] 儲存變更：$newNickname");
    await userController.updateProfile(newNickname, previewUrl.value);
  }
}
