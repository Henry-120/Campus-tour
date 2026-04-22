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
      if (widget.monsterModel.architectureRef != null) {
        final result = await _controller.getStory(
          widget.monsterModel.architectureRef!,
        );
        setState(() {
          story = result;
          isLoading = false;
        });
      } else {
        setState(() {
          story = "目前沒有此精靈的故事資料。";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        story = "載入故事失敗: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 直接使用 monster.json 中定義的完整路徑
    // 例如: assets/images/fairy_img/zhongda_lake.jpg
    String imagePath = widget.monsterModel.imageURL;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.monsterModel.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顯示 Asset 圖片
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("圖片載入失敗路徑: $imagePath");
                      return Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text("圖片路徑錯誤:\n$imagePath", 
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.monsterModel.name,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.monsterModel.type,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "傳說故事",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
              ),
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    story ?? "沒有故事資料",
                    style: const TextStyle(fontSize: 17, height: 1.6, color: Colors.black87),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
