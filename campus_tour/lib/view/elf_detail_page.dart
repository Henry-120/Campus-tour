import 'package:campus_tour/models/monster_model.dart';
import 'package:flutter/material.dart';
import '../controllers/encyclopedia_controller.dart';

class ElfDetailPage extends StatefulWidget {
  final MonsterModel monsterModel;

  const ElfDetailPage({super.key, required this.monsterModel});

  @override
  State<ElfDetailPage> createState() => _ElfDetailPageState();
}

class _ElfDetailPageState extends State<ElfDetailPage> {
  final EncyclopediaController _controller = EncyclopediaController();
  String? story;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    try {
      final result = await _controller.getStory(
        widget.monsterModel.architectureRef!,
      );
      setState(() {
        story = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        story = "載入故事失敗: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.monsterModel.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.network(widget.monsterModel.imageURL, height: 200),
            const SizedBox(height: 16), //間隔
            Text(
              widget.monsterModel.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ), //名字
            const SizedBox(height: 8),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Text("Story: ${story ?? "沒有故事資料"}"),
          ],
        ),
      ),
    );
  }
}
