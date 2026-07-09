import 'package:flutter/material.dart';
import '../../../styles/app_theme.dart';

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
                Text(
                  '捕捉失敗',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '失敗',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 18,
                    color: Colors.black54,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
