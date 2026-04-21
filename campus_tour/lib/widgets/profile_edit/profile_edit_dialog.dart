import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_edit_controller.dart';
import 'avatar_preview.dart';
import 'nickname_field.dart';

class ProfileEditDialog extends StatelessWidget {
  const ProfileEditDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 使用 Get.put 確保 Controller 在 Dialog 顯示期間存在
    final controller = Get.put(ProfileEditController());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.orange.shade200, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            AvatarPreview(controller: controller),
            const SizedBox(height: 12),
            const Text(
              "點擊頭像生成隨機 BigHead",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 25),
            NicknameField(controller: controller),
            const SizedBox(height: 30),
            _buildActions(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome, color: Colors.orange.shade400, size: 28),
        const SizedBox(width: 8),
        const Text(
          '更換造型',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.auto_awesome, color: Colors.orange.shade400, size: 28),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ProfileEditController controller) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('先不要', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await controller.saveProfile();
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('確定更換', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
