import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'dart:async'; // 非同步處理

class NFCservice {
  static const String _ios_alert_mes = "請靠近NFC感應";
  // static const String _error_ios_mes = "讀取發生錯誤";
  static const String _nfca_error_mes = "NfcA 格式錯誤";

  //return future 式api // 主要api
  static Future<NfcResponse?> scanSingleTag() async {
    //  檢查硬體
    if (!await isAvailability()) {
      return NfcResponse.error(NfcErrorType.hardwareDisabled);
    }

    //  使用 Completer 來將非同步的監聽轉為可等待的 Future
    final completer = Completer<NfcResponse?>();

    NfcManager.instance.startSession(
      alertMessage: _ios_alert_mes,
      onError: (NfcError error) async {
        // 只要發生錯誤或取消，就封口並回傳 null
        if (!completer.isCompleted) {
          completer.complete(NfcResponse.error(NfcErrorType.userCanceled));
        }
      },
      onDiscovered: (NfcTag tag) async {
        try {
          //  讀到標籤後，立刻解析
          final result = _nFCDataAns125(tag);

          // 讀到就停止，這會自動關閉 iOS 的掃描視窗
          await NfcManager.instance.stopSession();

          // 完成這個 Future 並回傳結果
          if (!completer.isCompleted) {
            completer.complete(NfcResponse.success(result));
          }
        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: e.toString());
          if (!completer.isCompleted) {
            completer.complete(
              NfcResponse.error(
                NfcErrorType.parseFailed,
                errorMessage: e.toString(),
              ),
            );
          }
        }
      },
    );

    // 這裡會一直等待，直到上面呼叫了 complete
    return completer.future;
  }

  //檢查是否支援
  static Future<bool> isAvailability() async {
    final availability = await NfcManager.instance.isAvailable();
    return availability;
  }

  //分析器
  static NfcScanResult _nFCDataAns125(NfcTag tag) {
    final nfcA = NfcA.from(tag);
    if (nfcA == null)
      throw Exception(_nfca_error_mes);
    else {
      String uid = nfcA.identifier
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join(':')
          .toUpperCase();
      return NfcScanResult(tagId: uid, tagType: "NTAG215", rawData: tag.data);
    }
  }

  // static NfcScanResult _nFCDataAns242(NfcTag tag) {
  //   return tag.data;
  // }

  //觸發停止
  static Future<void> stopScanning() async {
    await NfcManager.instance.stopSession();
  }
}

class NfcScanResult {
  final String tagId; // 標籤的唯一實體 ID (UID)
  final String? dynamicUrl; // 如果是 424，這裡會有帶 CMAC 的 URL
  final String tagType; // "NTAG215" 或 "NTAG424"
  final Map<String, dynamic> rawData; // 留著備用的原始資料

  NfcScanResult({
    required this.tagId,
    this.dynamicUrl,
    required this.tagType,
    required this.rawData,
  });
}

enum NfcErrorType {
  userCanceled, // 使用者主動取消 (iOS 視窗按取消或手動呼叫 stop)
  hardwareDisabled, // NFC 沒開
  parseFailed, // 格式不對 (不是 NTAG215)
  unknown, // 其他未知錯誤
}

class NfcResponse {
  final NfcScanResult? _data;
  final NfcErrorType? _error;
  final String? errorMessage;

  NfcResponse.success(this._data) : _error = null, errorMessage = null;
  NfcResponse.error(this._error, {this.errorMessage}) : _data = null;
  //執行檢查
  bool get isSuccess => _data != null;

  //封裝取出
  NfcScanResult get data {
    if (_data == null) {
      // 如果內部資料是空的，代表這是一個失敗的 Response
      // 我們直接拋出異常，阻止程式繼續執行
      throw StateError("錯誤：嘗試在掃描失敗的情況下讀取 Data。請先檢查 isSuccess！");
    }
    return _data; // 否則，安全地回傳資料
  }

  // --- 重點：封裝後的 Error 存取器 ---
  NfcErrorType get error {
    if (_error == null) {
      throw StateError("錯誤：嘗試在掃描成功的情況下讀取 Error 類型。");
    }
    return _error;
  }
}
