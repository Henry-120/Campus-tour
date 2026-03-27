// import 'package:flutter/material.dart';

// Abc for class
// a_b_c for var
//aBc for funtion

class WeatherApi {
  static Future<String> nowWeather() async {
    await Future.delayed(const Duration(seconds: 2));
    return "rain";
  }
}
