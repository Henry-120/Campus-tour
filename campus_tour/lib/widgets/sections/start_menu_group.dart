import 'package:flutter/material.dart';
import '../buttons/start_button.dart';
import '../../view/login_page.dart';

class StartMenuGroup extends StatelessWidget {
  const StartMenuGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 💡 放大寬度到螢幕的 1.1 倍
    final textImageWidth = screenWidth * 0.9;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. 標題圖片
        SizedBox(
          width: textImageWidth,
          child: Image.asset(
            'assets/images/start_text.png',
            width: textImageWidth,
            fit: BoxFit.contain,
            // 💡 加入除錯：如果路徑有誤，畫面上會出現紅色文字
            errorBuilder: (context, error, stackTrace) {
              debugPrint("❌ [StartMenuGroup] 圖片載入失敗: $error");
              return Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  Text("載入失敗: start_text.png\n$error",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              );
            },
          ),
        ),
        
        // 💡 增加間距
        SizedBox(height: screenHeight*0.25),
        
        // 2. 開始按鈕
        const StartButton(
          label: "開始",
          destination: LoginPage(),
        ),
      ],
    );
  }
}
