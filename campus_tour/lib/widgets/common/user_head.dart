import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../constants/asset_paths.dart';
import 'show_edit_profile.dart';

class UserHead extends StatelessWidget {
  final double size;

  const UserHead({
    super.key,
    this.size = 95,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      final user = userController.userModel.value;
      final photoUrl = user?.photoUrl;

      return GestureDetector(
        onTap: () => showEditProfileDialog(context, userController),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [

              // 2. 最上層木框圖片
              // 外層是正方形，所以右下角指南針不會被切掉
              Positioned.fill(
                child: Image.asset(
                  AssetPaths.userHeadBorder,
                  fit: BoxFit.contain,
                ),
              ),

              // 1. 中間圓形頭像
              Positioned(
                child: ClipOval(
                  child: SizedBox(
                    width: size * 0.66,
                    height: size * 0.66,
                    child: _buildAvatar(photoUrl),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAvatar(String? url) {
    if (url == null || url.isEmpty) {
      return _buildDefaultIcon();
    }

    final isSvg = url.toLowerCase().contains(".svg") ||
        url.toLowerCase().contains("svg") ||
        url.contains("netlify");

    if (isSvg) {
      return SvgPicture.network(
        url,
        key: ValueKey(url),
        fit: BoxFit.cover,
        placeholderBuilder: (context) => _buildDefaultIcon(),
        errorBuilder: (context, error, stackTrace) {
          debugPrint("[UserHead] SVG 載入失敗: $error");
          return _buildDefaultIcon();
        },
      );
    } else {
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
      color: const Color(0xFFFFE8B8),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: size * 0.38,
          color: const Color(0xFFB8793E),
        ),
      ),
    );
  }
}