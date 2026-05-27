import 'package:campus_tour/controllers/nfc_api.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/styles/nfc_leading_style.dart';
import 'package:campus_tour/widgets/common/snackbar_builder.dart';

class NfcButtonAbstract extends StatelessWidget {
  final Icon nfcIcon = NfcLeadingStyle.nfcIcon;
  final String text;
  final VoidCallback onPressedToDo;
  final ButtonStyle nowStyle;

  const NfcButtonAbstract({
    super.key,
    required this.text,
    required this.onPressedToDo,
    required this.nowStyle,
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: nfcIcon,
      style: nowStyle,
      onPressed: onPressedToDo,
      label: Text(text, style: NfcLeadingStyle.primaryButtonText),
    );
  }
}

//實例化
class NfcButton1 extends StatefulWidget {
  // The expected tag id to match against the scanned tag.
  final String ans;
  // Called when a matching tag is scanned. No parameters — the button
  // performs the comparison internally.
  final VoidCallback onResult; // 成功感應後的動作 (no args)
  const NfcButton1({super.key, required this.ans, required this.onResult});
  @override
  State<StatefulWidget> createState() {
    return _NfcButton1();
  }
}

class _NfcButton1 extends State<NfcButton1> {
  bool _isScanning = false; // 控制按鈕狀態的關鍵

  Future<void> onPressed() async {
    if (_isScanning) {
      await NFCservice.stopScanning();
      setState(() => _isScanning = false);
      return;
    } else {
      // 開始掃描
      setState(() => _isScanning = true);

      try {
        // 呼叫 API 並取得封裝好的 Response
        NfcResponse? response = await NFCservice.scanSingleTag();
        if (response == null) throw StateError("Undefult Error return Error");

        // 只有在使用者還沒手動按停止 (isScanning 仍為 true) 時才處理結果
        if (mounted && _isScanning) {
          if (response.isSuccess) {
            // --- 成功：透過 .data 取得結果 ---
            final tagId = response.data.tagId;
            // 比對是否符合預期的 ans
            if (tagId == widget.ans) {
              widget.onResult();
            } else {
              // 不符合則顯示錯誤訊息
              SnackBarBuilder.show(
                context,
                'ID 不符合，請重新嘗試！',
                type: AppToastType.warning,
              );
            }
          } else {
            // --- 失敗：處理錯誤類型 ---
            _handleError(response.error);
          }
        }
      } catch (e) {
        // 處理未預期的系統異常 (例如網路中斷或實體毀損)
        debugPrint("系統層級錯誤: $e");
      } finally {
        // 3. 結束後務必將狀態改回 false
        if (mounted) {
          setState(() => _isScanning = false);
        }
      }
    }
  }

  void _handleError(NfcErrorType errorType) {
    String message;
    switch (errorType) {
      case NfcErrorType.userCanceled:
        message = "取消感應";
        break;

      case NfcErrorType.hardwareDisabled:
        //_showOpenSettingsDialog(); // 彈出視窗叫使用者去開 NFC
        message = "NFC權限未開放";
        break;

      case NfcErrorType.parseFailed:
        message = "標籤格式錯誤";
        break;

      default:
        debugPrint("發生未知錯誤");
        message = "發生未知錯誤";
    }
    // debugPrint("NFC 掃描失敗: $errorType, 訊息: $message");

    // 在這裡根據錯誤類型彈出不同的 mes
    SnackBarBuilder.show(
      context,
      message,
      type: errorType == NfcErrorType.userCanceled
          ? AppToastType.info
          : AppToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NfcButtonAbstract(
      text: _isScanning
          ? NfcLeadingStyle.nfcIngString
          : NfcLeadingStyle.primaryButtonString,
      onPressedToDo: onPressed,
      nowStyle: _isScanning
          ? NfcLeadingStyle.nfcIngStyle
          : NfcLeadingStyle.primaryButtonStyle,
    );
  }
}
