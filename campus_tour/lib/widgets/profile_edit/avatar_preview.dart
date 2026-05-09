import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/profile_edit_controller.dart';
import '../constants/responsive.dart';


class AvatarPreview extends StatelessWidget {
  final ProfileEditController controller;

  const AvatarPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final avatarSize = Responsive.s(context, 120);
    final refreshRadius = Responsive.s(context, 18);

    return GestureDetector(
      onTap: controller.generateRandomAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.orange.shade200,
                width: Responsive.s(context, 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: Responsive.s(context, 10),
                  offset: Offset(0, Responsive.s(context, 4)),
                ),
              ],
            ),
            child: ClipOval(
              child: Obx(() {
                final url = controller.previewUrl.value;
                if (url == null || url.isEmpty) {
                  return _buildDefaultIcon(context);
                }

                return SvgPicture.network(
                  url,
                  key: ValueKey(url),
                  fit: BoxFit.contain,
                  width: avatarSize,
                  height: avatarSize,
                  placeholderBuilder: (context) => Center(
                    child: SizedBox(
                      width: Responsive.s(context, 30),
                      height: Responsive.s(context, 30),
                      child: CircularProgressIndicator(
                        strokeWidth: Responsive.s(context, 2),
                        color: Colors.orange,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.orange.shade400,
            radius: refreshRadius,
            child: Icon(
              Icons.refresh,
              color: Colors.white,
              size: Responsive.s(context, 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      color: Colors.orange.shade50,
      child: Icon(
        Icons.person,
        size: Responsive.s(context, 60),
        color: Colors.grey,
      ),
    );
  }
}
