import 'package:campus_tour/models/monster_model.dart';
import 'package:flutter/material.dart';
import '../controllers/encyclopedia_controller.dart';
import '../models/architecture_model.dart';
import '../widgets/encyclopedia/elf_creator_section.dart';
import '../widgets/encyclopedia/elf_department_section.dart';
import '../widgets/encyclopedia/elf_hero_section.dart';
import '../widgets/encyclopedia/elf_installation_section.dart';
import '../widgets/encyclopedia/elf_story_section.dart';
import '../widgets/encyclopedia/elf_type_tag.dart';

class ElfDetailPage extends StatefulWidget {
  final MonsterModel monsterModel;

  const ElfDetailPage({
    super.key,
    required this.monsterModel,
  });

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
    final imagePath = widget.monsterModel.imageURL;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor.withValues(alpha: 0.85),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFDCE9FF),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: primaryColor,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          widget.monsterModel.name,
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
              name: widget.monsterModel.name,
              type: widget.monsterModel.type,
            ),

            ElfTypeTag(
              type: widget.monsterModel.type,
            ),

            ElfStorySection(
              story: architecture?.story ?? '目前沒有此精靈的故事資料。',
              isLoading: isLoading,
            ),

            if (architecture?.type == '裝置藝術') ...[
              ElfInstallationSection(
                imagePath: architecture?.imageURL ?? '',
                location: architecture?.name ?? '目前沒有裝置藝術資料',
                year: architecture?.date ?? '',
              ),

              ElfCreatorSection(
                creatorName: architecture?.author ?? '未知作者',
              ),
            ],

            if (architecture?.type == '系館') ...[
              ElfDepartmentSection(
                major: architecture?.major,
              ),
            ],
          ],
        ),
      ),
    );
  }
}