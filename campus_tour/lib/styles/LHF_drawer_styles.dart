import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Abc for class
// a_b_c for var
//aBc for funtion

class DrawerStyles {
  //左拉選單的樣式設定
  // color
  static const Color sunny_color = Colors.blue;
  static const Color rain_color = Colors.grey;
  static const Color sbutton_font_color = Colors.white;
  static const Color sbutton_side_color = Colors.transparent;
  static const Color sbutton_bg_color = Colors.transparent;

  //path
  static const String rain_image_path = "assets/images/weather/raining.png";
  static const String sunny_image_path = "assets/images/weather/sunny.png";

  //animate time
  static const int rain_to_sunny = 1500;

  //對齊格式
  static const drawer_main_alignment = MainAxisAlignment.start;
  static const drawer_cross_alignment = CrossAxisAlignment.stretch;

  //side width
  static const double sbutton_side_width = 1.5;

  //size
  static const Size sbutton_size = Size(100, 75);

  //button style
  static ButtonStyle drawer_button_style = OutlinedButton.styleFrom(
    foregroundColor: sbutton_font_color,
    backgroundColor: sbutton_bg_color,
    side: const BorderSide(
      color: sbutton_side_color, // 邊框也設為橘色
      width: sbutton_side_width, // 邊框粗細
    ),
    minimumSize: sbutton_size,
  );

  //Text Style
  static final TextStyle second_button_text = GoogleFonts.zcoolQingKeHuangYou(
    fontSize: 26,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2, // 稍微拉開字距，更有質感
  );
}

class DrawerWeatherTrans {
  static AssetImage weatherToColor(String? weather) {
    //判斷天氣對應的狀況
    switch (weather) {
      case ("rain"):
        return AssetImage(DrawerStyles.rain_image_path);
      case ('sunny'):
        return AssetImage(DrawerStyles.sunny_image_path);
      default:
        return AssetImage(DrawerStyles.sunny_image_path);
    }
  }
}
