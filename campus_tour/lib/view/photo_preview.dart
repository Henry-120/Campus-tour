import 'dart:io';
import 'package:flutter/material.dart';

class PhotoPreviewPage extends StatelessWidget {
  final String imagePath;

  const PhotoPreviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('照片預覽'),
        backgroundColor: Colors.black,
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
                  onPressed: () => Navigator.pop(context), // 回去重拍
                  child: const Text('重拍'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 這裡可以寫存檔或分享的邏輯
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('照片已儲存')),
                    );
                  },
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