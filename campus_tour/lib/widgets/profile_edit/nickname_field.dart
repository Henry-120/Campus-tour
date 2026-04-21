import 'package:flutter/material.dart';
import '../../controllers/profile_edit_controller.dart';

class NicknameField extends StatelessWidget {
  final ProfileEditController controller;

  const NicknameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            '新的稱呼',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.face_rounded, color: Colors.orange.shade300),
            hintText: '目前的暱稱：${controller.userController.userModel.value?.nickname ?? "冒險者"}',
            hintStyle: TextStyle(color: Colors.orange.shade200, fontSize: 14),
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }
}
