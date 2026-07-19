import 'package:campus_tour/models/monster_model.dart';
import 'package:flutter/material.dart';
import '../controllers/encyclopedia_controller.dart';
import '../models/architecture_model.dart';
import '../styles/app_theme.dart';
import '../utils/monster_image_path.dart';
import '../widgets/encyclopedia/elf_creator_section.dart';
import '../widgets/encyclopedia/elf_department_section.dart';
import '../widgets/encyclopedia/elf_hero_section.dart';
import '../widgets/encyclopedia/elf_installation_section.dart';
import '../widgets/encyclopedia/elf_story_section.dart';
import '../widgets/encyclopedia/elf_type_tag.dart';

import 'package:get/get.dart';

class ElfDetailPage extends StatefulWidget {
  final MonsterModel monsterModel;

  const ElfDetailPage({super.key, required this.monsterModel});

  @override
  State<ElfDetailPage> createState() => _ElfDetailPageState();
}

class _ElfDetailPageState extends State<ElfDetailPage> {
  final EncyclopediaController _controller = EncyclopediaController();

  ArchitectureModel? architecture;
  bool isLoading = true;

  static const Color primaryColor = Color(0xFF006C49);
  static const Color backgroundColor = Color(0xFFF8F9FF);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (widget.monsterModel.architectureRef != null) {
        final arch = await _controller.getArchitecture(
          widget.monsterModel.architectureRef!,
        );

        if (!mounted) return;

        setState(() {
          architecture = arch;
          isLoading = false;
          debugPrint("architecture: ${architecture?.imageURL}");
        });
      } else {
        if (!mounted) return;

        setState(() {
          architecture = null;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        architecture = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = MonsterImagePath.staticImage(
      widget.monsterModel.imageURL,
    );
    final displayName = architecture?.name ?? widget.monsterModel.name;
    final displayType = architecture?.type ?? widget.monsterModel.type;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor.withValues(alpha: 0.85),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Color(0xFFDCE9FF),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          displayName,
          style: AppTheme.titleStyle.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElfHeroSection(
              imagePath: imagePath,
              name: displayName,
              type: displayType,
            ),

            ElfTypeTag(type: displayType),

            ElfStorySection(
              name: architecture?.name ?? 'view.elf.detail.page.s001'.tr,
              story: architecture?.story ?? 'view.elf.detail.page.s002'.tr,
              isLoading: isLoading,
            ),

            if (architecture?.canonicalType ==
                ArchitectureModel.installationArt) ...[
              ElfInstallationSection(
                imagePath: architecture?.imageURL ?? '',
                location: architecture?.name ?? 'view.elf.detail.page.s004'.tr,
                year: architecture?.date ?? '',
              ),

              ElfCreatorSection(
                creatorName:
                    architecture?.author ?? 'view.elf.detail.page.s005'.tr,
              ),
            ],

            if (architecture?.canonicalType ==
                ArchitectureModel.departmentBuilding) ...[
              ElfDepartmentSection(major: architecture?.major),
            ],
          ],
        ),
      ),
    );
  }
}
