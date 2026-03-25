import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'view/start_page.dart'; // 引入拆分後的開始頁面

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 移除狀態列與虛擬按鍵，進入沉浸模式
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(), // 指向 lib/view/start_page.dart
    );
  }
}