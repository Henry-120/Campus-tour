import 'package:flutter/material.dart';
import "package:campus_tour/styles/LHF_drawer_styles.dart";

// Abc for class
// a_b_c for var
//aBc for funtion

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
