import 'package:campus_tour/models/monster_model.dart';
import 'package:flutter/material.dart';
import '../controllers/encyclopedia_controller.dart';

class MonsterEncyclopediaPage extends StatelessWidget {
  // 1. 定義接收的變數為 String
  final String monsterName;
  final String? monsterStory;

  // 2. 修改建構函式，要求傳入這兩個 String
  const MonsterEncyclopediaPage({
    super.key,
    required this.monsterName,
    required this.monsterStory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('怪物卡')),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 上半部分：圖片區域
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: Image.asset(
                        'assets/$monsterName', // 使用傳入的 monsterName
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 下半部分：文字故事區域
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          monsterStory ?? "沒有故事資料", // 3. 這裡直接使用接收來的 String
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(onPressed: () {}, child: const Text('按鈕')),
          ],
        ),
      ),
    );
  }
}
