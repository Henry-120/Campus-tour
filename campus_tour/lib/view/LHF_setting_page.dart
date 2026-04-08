import 'package:flutter/material.dart';

// not my res now , this is only the exp page
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定中心')),
      body: const Center(child: Text('這裡是設定頁面內容')),
    );
  }
}
