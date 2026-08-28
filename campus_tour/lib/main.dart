import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'view/start_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'controllers/monster_controller.dart';
import 'controllers/location_controller.dart';
import 'controllers/nfc_scan_controller.dart';
import 'controllers/reviewer_access_controller.dart';
import 'controllers/user_controller.dart';
import 'l10n/app_translations.dart';
import 'package:get/get.dart';
import 'local_information/local_setting.dart';
import 'services/audio_service.dart';
import 'services/orientation_service.dart';
import 'styles/app_theme.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalSettingService.initBox();
  await AudioService().initializeVolume();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await OrientationService.lockPortrait();

  // 💡 預先注入 Controller，內部的 onInit 會自動監聽 Firebase Auth 狀態

  Get.put(ReviewerAccessController(), permanent: true);
  Get.put(LocationController(), permanent: true);
  Get.put(MonsterController());
  Get.put(NfcScanController());
  Get.put(UserController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Locale(LocalSettingService.language.current),
      fallbackLocale: const Locale(LanguageSetting.chinese),
      theme: AppTheme.themeData,
      navigatorObservers: [routeObserver],
      home: StartPage(),
    );
  }
}
