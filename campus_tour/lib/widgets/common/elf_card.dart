import 'package:flutter/material.dart';
import '../../models/user_monster_model.dart';
import '../../styles/app_theme.dart';
import '../../utils/monster_image_path.dart';
import '../constants/asset_paths.dart';
import '../constants/responsive.dart';

class ElfCard extends StatelessWidget {
  final UserMonsterModel item;
  final VoidCallback onTap;

  const ElfCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    final imagePath = MonsterImagePath.staticImage(item.imageURL);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14 * scale),
      child: Container(
        margin: EdgeInsets.all(2 * scale),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.book),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12 * scale,
            14 * scale,
            12 * scale,
            12 * scale,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 6 * scale),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorState(scale);
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 4 * scale),

              Text(
                item.name,
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.gameTextColor,
                  letterSpacing: 0,
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

  Widget _buildErrorState(double scale) {
    return Center(
      child: Icon(
        Icons.broken_image,
        color: AppTheme.errorColor.withValues(alpha: 0.7),
        size: 22 * scale,
      ),
    );
  }
}
