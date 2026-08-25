import 'package:campus_tour/features/station_hardware/constants/sakura_assets.dart';
import 'package:campus_tour/models/user_monster_model.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/utils/monster_image_path.dart';
import 'package:flutter/material.dart';

class SakuraMonsterChoiceCard extends StatelessWidget {
  const SakuraMonsterChoiceCard({
    super.key,
    required this.monster,
    required this.onTap,
  });

  final UserMonsterModel monster;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: monster.name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(SakuraAssets.pickerCard),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Image.asset(
                        MonsterImagePath.staticImage(monster.imageURL),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF9B6B5E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monster.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTheme.cardTitleStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.gameTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
