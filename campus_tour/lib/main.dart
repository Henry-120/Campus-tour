import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'view/login_page.dart'; // 變更為直接從登入頁開始
import 'view/start_page.dart'; // 開始頁面
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'services/load_db_service.dart';
import 'controllers/monster_controller.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //初始化 db
  await LoadDbService().loadArchitecture();
  await LoadDbService().loadQA();
  await LoadDbService().loadMonsters();
  debugPrint("db loaded");

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  Get.put(MonsterController()); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: LoginPage(), // 直接顯示登入頁面,
      home: StartPage(), // 直接顯示開始頁面,
    );
  }
}
