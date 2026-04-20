import 'package:flutter/material.dart';
import '../../models/user_monster_model.dart';
import '../../styles/app_theme.dart';

class ElfCard extends StatelessWidget {
  final UserMonsterModel item;
  final VoidCallback onTap;

  const ElfCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String imagePath = item.imageURL.trim();
    if (imagePath.isNotEmpty && !imagePath.startsWith('assets/')) {
      imagePath = 'assets/images/fairy_img/$imagePath';
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.cardPadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => _buildErrorState(imagePath),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 4, right: 4),
              child: Text(
                item.name,
                style: AppTheme.cardTitleStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String path) {
    return Container(
      width: double.infinity,
      color: AppTheme.errorColor.withValues(alpha: 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: AppTheme.errorColor, size: 20),
          Text(
            path.split('/').last, 
            style: TextStyle(fontSize: 8, color: AppTheme.errorColor.withOpacity(0.7)),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
