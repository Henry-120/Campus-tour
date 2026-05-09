import 'package:campus_tour/models/monster_model.dart';
import 'package:flutter/material.dart';
import '../controllers/encyclopedia_controller.dart';
import '../widgets/encyclopedia/elf_creator_section.dart';
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

  String? story;
  bool isLoading = true;

  static const Color primaryColor = Color(0xFF006C49);
  static const Color backgroundColor = Color(0xFFF8F9FF);

  final String installationLocation = 'Main Courtyard';
  final String installationYear = '2023';
  final String creatorName = 'Aris Thorne';

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    try {
      if (widget.monsterModel.architectureRef != null) {
        final result = await _controller.getStory(
          widget.monsterModel.architectureRef!,
        );

        if (!mounted) return;

        setState(() {
          story = result;
          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          story = "目前沒有此精靈的故事資料。";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        story = "載入故事失敗: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.monsterModel.imageURL;
    String archPath = "assets/images/大象五行.png";

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
        title: const Text(
          'Spirit Profile',
          style: TextStyle(
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
              story: story,
              isLoading: isLoading,
            ),
            ElfInstallationSection(
              imagePath: archPath,
              location: installationLocation,
              year: installationYear,
            ),
            ElfCreatorSection(
              creatorName: creatorName,
            ),
          ],
        ),
      ),
    );
  }
}