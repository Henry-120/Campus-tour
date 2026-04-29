import 'package:campus_tour/view/game_main_page.dart';
import 'package:flutter/material.dart';

class CatchingFaildPage extends StatelessWidget {
  const CatchingFaildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sentiment_dissatisfied,
                  size: 120,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  '捕捉失敗',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '失敗',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameMainPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('回到首頁'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
