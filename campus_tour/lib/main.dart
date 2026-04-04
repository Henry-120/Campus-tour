import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'view/start_page.dart'; // 引入拆分後的開始頁面
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // FlutterFire CLI 產生的檔案
import 'services/load_db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //初始化 db (之後要拿掉)
  await LoadDbService().loadArchitecture();
  await LoadDbService().loadQA();
  await LoadDbService().loadMonsters();
  debugPrint("db loaded");

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