import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  /// 💡 啟動相機拍照
  Future<void> takePhoto() async {
    try {
      // 1. 呼叫系統相機
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear, // 使用後鏡頭
      );

      if (photo == null) {
        debugPrint('[Camera]:使用者取消了拍照');
        return;
      }

      // 2. 拿到照片路徑 (未來可以用來上傳或顯示)
      debugPrint('[Camera]:拍照成功！路徑：${photo.path}');
      
      // 你可以在這裡加入邏輯，例如：把照片存進圖鑑
    } catch (e) {
      debugPrint('[Camera]:相機出錯：$e');
    }
  }
}