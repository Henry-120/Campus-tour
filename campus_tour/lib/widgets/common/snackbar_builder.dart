import 'package:flutter/material.dart';

class SnackBarBuilder {
  static SnackBar showOut(String mes) {
    return SnackBar(
      content: Text(mes),
      duration: Duration(seconds: 2), // 設定停留時間，預設通常是 4 秒
      behavior: SnackBarBehavior.floating, // 讓它「浮起來」，看起來更現代
    );
  }
}
