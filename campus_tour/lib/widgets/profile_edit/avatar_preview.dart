import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/profile_edit_controller.dart';

class AvatarPreview extends StatelessWidget {
  final ProfileEditController controller;
  
  const AvatarPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.generateRandomAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // 💡 設為白色背景，SVG 渲染更清楚
              border: Border.all(color: Colors.orange.shade200, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: ClipOval(
              child: Obx(() {
                final url = controller.previewUrl.value;
                if (url == null || url.isEmpty) {
                  return _buildDefaultIcon();
                }

                // 💡 在手機端，ValueKey 非常重要，強迫 Flutter 每次重新渲染新的 URL
                return SvgPicture.network(
                  url,
                  key: ValueKey(url), 
                  fit: BoxFit.contain,
                  width: 120,
                  height: 120,
                  // 💡 增加載入與錯誤處理
                  placeholderBuilder: (context) => const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                    ),
                  ),
                );
              }),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.orange.shade400,
            radius: 18,
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: Colors.orange.shade50,
      child: const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }
}
