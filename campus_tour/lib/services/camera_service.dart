import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  // 新增這個方法，專門處理「已經拍好的照片路徑」
  void handleCapturedPath(String path) {
    debugPrint('[Camera]: AR捕捉成功！路徑：$path');

    // 未來你可以在這裡寫：
    // 1. 上傳到 FastAPI 做 YOLO 辨識
    // 2. 儲存到 Firestore 的精靈圖鑑
    // 3. 彈出成功視窗
  }

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