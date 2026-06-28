import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/common/snackbar_builder.dart';

import 'package:get/get.dart';

class PhotoPreviewPage extends StatelessWidget {
  final String imagePath;

  PhotoPreviewPage({super.key, required this.imagePath});

  Future<void> _savePhoto(BuildContext context) async {
    try {
      // 檢查並請求權限
      var hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (!hasAccess) {
        if (context.mounted) {
          _showPhotoPermissionDialog(context);
        }
        return;
      }

      // 儲存照片到相簿
      await Gal.putImage(imagePath);

      if (context.mounted) {
        SnackBarBuilder.show(
          context,
          'view.photo.preview.s001'.tr,
          type: AppToastType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarBuilder.show(context, '儲存失敗: $e', type: AppToastType.error);
      }
    }
  }

  void _showPhotoPermissionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('需要相簿權限'),
          content: Text('需要相簿權限才能儲存照片。請到系統設定開啟相簿存取權後再試一次。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('稍後再說'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
              child: Text('開啟設定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('view.photo.preview.s003'.tr),
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
                  child: Text('view.photo.preview.s004'.tr),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _savePhoto(context), // 執行儲存邏輯
                  child: Text('view.photo.preview.s005'.tr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
