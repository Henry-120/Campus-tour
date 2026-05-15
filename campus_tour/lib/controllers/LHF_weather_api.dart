// import 'package:flutter/material.dart';

class WeatherApi {
  static Future<String> nowWeather() async {
    await Future.delayed(const Duration(seconds: 2));
    return "rain";
  }
}
