import 'package:flutter/material.dart';
import '../../models/user_monster_model.dart';
import '../../styles/app_theme.dart';
import '../constants/asset_paths.dart';

class ElfCard extends StatelessWidget {
  final UserMonsterModel item;
  final VoidCallback onTap;

  const ElfCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath = item.imageURL.trim();

    if (imagePath.isNotEmpty && !imagePath.startsWith('assets/')) {
      imagePath = 'assets/images/fairy_img/$imagePath';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.book),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorState(imagePath);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                item.name,
                style: AppTheme.cardTitleStyle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF4A2F25),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String path) {
    return Center(
      child: Icon(
        Icons.broken_image,
        color: AppTheme.errorColor.withValues(alpha: 0.7),
        size: 22,
      ),
    );
  }
}