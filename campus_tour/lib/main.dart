import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'view/login_page.dart'; // 變更為直接從登入頁開始
import 'view/start_page.dart'; // 開始頁面
=======
import 'view/start_page.dart';
>>>>>>> origin/main
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'services/load_db_service.dart';
import 'controllers/monster_controller.dart';
import 'controllers/user_controller.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 初始化 db
  // await LoadDbService().loadArchitecture();
  // await LoadDbService().loadQA();
  // await LoadDbService().loadMonsters();
  // 💡 預先注入 Controller，內部的 onInit 會自動監聽 Firebase Auth 狀態
  Get.put(MonsterController()); 
  Get.put(UserController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      //home: LoginPage(), // 直接顯示登入頁面,
      home: StartPage(), // 直接顯示開始頁面,
=======
      home: StartPage(),
>>>>>>> origin/main
    );
  }
}
