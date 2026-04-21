import 'package:flutter/material.dart';
import 'package:campus_tour/widgets/buttons/circle_icon_button.dart';
import 'package:campus_tour/view/encyclopedia_page.dart';
import '../../view/Camera_view.dart';
import '../../view/Real_ar_view.dart';

class SystemMenu extends StatelessWidget {
  const SystemMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleIconButton(
          icon: Icons.auto_stories,
          label: '圖鑑',
          onTap: () => _navigateTo(context,'encyclopedia'),
        ),
        const SizedBox(height: 12),
        CircleIconButton(
          icon: Icons.camera_alt,
          label: '相機',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ArCapturePage(),
            ),
          ),
        ),

        CircleIconButton(
          icon: Icons.auto_awesome,
          label: 'AR',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RealArPage (),
            ),
          ),
        ),
      ],
    );
  }
}
void _navigateTo(BuildContext context, String pageType) {
  // 宣告一個變數來儲存目標頁面
  Widget destination;

  // 根據傳入的字串判斷要跳轉到哪一個 Widget
  if (pageType == 'encyclopedia') {
    destination = const EncyclopediaPage();
  } else {
    // 預設跳轉
    destination = const SystemMenu();
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => destination,
    ),
  );
}

