import 'package:flutter/material.dart';
import '../../models/user_monster_model.dart';

class ElfCard extends StatelessWidget {
  final UserMonsterModel item;
  final VoidCallback onTap;

  const ElfCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 1. 修正路徑邏輯：確保路徑完整
    String imagePath = item.imageURL.trim();

    // 如果資料庫只存檔名 (例如 zhongda_lake.jpg)，則幫它補上完整路徑
    if (imagePath.isNotEmpty && !imagePath.startsWith('assets/')) {
      imagePath = 'assets/images/fairy_img/$imagePath';
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. 顯示圖片
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath, // 這裡要使用處理過後的 imagePath
                    fit: BoxFit.contain,
                    // 3. 錯誤監控：如果還是跑不出來，會在畫面上直接顯示報錯路徑
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("❌ 圖片載入失敗: $imagePath");
                      return Container(
                        width: double.infinity,
                        color: Colors.red[50],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image, color: Colors.red, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              "路徑錯誤\n${imagePath.split('/').last}",
                              style: const TextStyle(fontSize: 8, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 怪物名稱
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 4, right: 4),
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}