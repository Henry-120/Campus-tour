import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import 'show_edit_profile.dart';

class UserHead extends StatelessWidget {
  final double size;
  const UserHead({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      final user = userController.userModel.value;
      final photoUrl = user?.photoUrl;

      debugPrint("[UserHead] 正在重繪, photoUrl: $photoUrl");

      return GestureDetector(
        onTap: () => showEditProfileDialog(context, userController),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: Colors.orange.shade200, width: 3),
          ),
          child: ClipOval(
            child: _buildAvatar(photoUrl),
          ),
        ),
      );
    });
  }

  Widget _buildAvatar(String? url) {
    if (url == null || url.isEmpty) {
      return _buildDefaultIcon();
    }

    // 💡 判斷是否為 SVG
    // 1. 檢查副檔名
    // 2. 檢查是否包含 "netlify" (您的隨機頭像服務)
    // 3. 檢查是否包含 "svg" 關鍵字
    final isSvg = url.toLowerCase().contains(".svg") || 
                  url.toLowerCase().contains("svg") ||
                  url.contains("netlify");

    if (isSvg) {
      return SvgPicture.network(
        url,
        key: ValueKey(url),
        fit: BoxFit.contain,
        placeholderBuilder: (context) => _buildDefaultIcon(),
        // 💡 增加錯誤處理，如果 SVG 載入失敗則顯示預設圖標
        errorBuilder: (context, error, stackTrace) {
          // debugPrint(url);
          debugPrint("[UserHead] SVG 載入失敗: $error");
          return _buildDefaultIcon();
        },
      );
    } else {
      // 💡 非 SVG 則使用普通圖片載入 (如 Google 原始頭像)
      return Image.network(
        url,
        key: ValueKey(url),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildDefaultIcon();
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint("[UserHead] 圖片載入失敗: $error");
          return _buildDefaultIcon();
        },
      );
    }
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: Colors.orange.shade50,
      child: Center(
        child: Icon(
            Icons.person_rounded,
            size: size * 0.6,
            color: Colors.orange.shade300
        ),
      ),
    );
  }
}
