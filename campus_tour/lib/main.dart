import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'view/start_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/load_db_service.dart';
import 'controllers/monster_controller.dart';
import 'controllers/user_controller.dart';
import 'package:get/get.dart';
import 'local_information/local_setting.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalSettingService.initBox();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 初始化 db
  // await LoadDbService().loadArchitecture();
  // await LoadDbService().loadQA();
  await LoadDbService().loadMonsters();
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
      home: StartPage(),
    );
  }
}
