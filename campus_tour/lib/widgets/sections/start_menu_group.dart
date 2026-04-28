import 'package:flutter/material.dart';

import '../buttons/start_button.dart';
import '../../view/login_page.dart';
import '../constants/responsive.dart';

class StartMenuGroup extends StatelessWidget {
  const StartMenuGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    final textImageWidth = 370 * scale;
    final titleButtonGap = 228 * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: textImageWidth,
          child: Image.asset(
            'assets/images/component/start_text.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint("❌ [StartMenuGroup] 圖片載入失敗: $error");

              return Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40 * scale,
                  ),
                  Text(
                    "載入失敗: start_text.png\n$error",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12 * scale,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        SizedBox(height: titleButtonGap),

        const StartButton(
          label: "開始",
          destination: LoginPage(),
        ),
      ],
    );
  }
}