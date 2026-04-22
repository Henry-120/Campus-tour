import 'package:flutter/material.dart';
import 'package:campus_tour/controllers/LHF_weather_api.dart';
import 'package:campus_tour/styles/LHF_drawer_styles.dart';
// import 'package:campus_tour/widgets/buttons/LHF_drawer_button.dart';
// import 'package:campus_tour/controllers/LHF_drawer_button_funtion.dart';
import 'package:campus_tour/widgets/sections/drawer_button_group.dart';
// import 'package:campus_tour/view/LHF_setting_page.dart';
import 'package:campus_tour/view/leading_nfc_page.dart';

// Abc for class
// a_b_c for var
//aBc for funtion

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AppDrawerState();
  }
}

class _AppDrawerState extends State<AppDrawer> {
  late Future<String> _now_weather;
  @override
  void initState() {
    super.initState();
    _now_weather = WeatherApi.nowWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: _now_weather, //抓取現在天氣
        builder: (context, snapshot) {
          final backgr_image = DrawerWeatherTrans.weatherToColor(snapshot.data);
          //builder內要回傳的東西

          return _ImageToWidget(image: backgr_image);
        },
      ),
    );
  }
}

class _ImageToWidget extends StatelessWidget {
  //放進feture內
  final AssetImage image;
  const _ImageToWidget({required this.image});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: DrawerStyles.rain_to_sunny,
      ), // 動畫時間
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image, // 直接放入 AssetImage 物件
          fit: BoxFit.cover, // 讓背景圖鋪滿整個容器
        ),
      ),
      child: const _DarwerButton(),
    );
  }
}

class _DarwerButton extends StatelessWidget {
  // 按鈕都在這裡 // 在sections裡面
  const _DarwerButton();

  @override
  Widget build(BuildContext context) {
    return DrawerButtonGroup();
  }
}
