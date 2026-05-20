import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class PhotoPreviewPage extends StatelessWidget {
  final String imagePath;

  const PhotoPreviewPage({super.key, required this.imagePath});

  Future<void> _savePhoto(BuildContext context) async {
    try {
      // 檢查並請求權限
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // 儲存照片到相簿
      await Gal.putImage(imagePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('照片已成功儲存到相簿！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('儲存失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('照片預覽'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(File(imagePath)), // 顯示拍好的照片檔案
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context), // 回去重拍
                  child: const Text('重拍'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _savePhoto(context), // 執行儲存邏輯
                  child: const Text('儲存'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
