import 'package:campus_tour/styles/nfc_leading_style.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/widgets/buttons/nfc_button.dart';
import 'package:campus_tour/controllers/NFC_api.dart';

class LeadingNfcPage extends StatefulWidget {
  final List<String> treasureID;
  final List<String> treasureText;
  const LeadingNfcPage({
    super.key,
    required this.treasureID,
    required this.treasureText,
  });
  @override
  State<StatefulWidget> createState() {
    return _LeadingNfcPage();
  }
}

class _LeadingNfcPage extends State<LeadingNfcPage> {
  int nowIndex = 0;

  void _checkNfcResult(String scannedId) {
    // 檢查感應到的 ID 是否符合目前進度要求的 ID
    if (scannedId == widget.treasureID[nowIndex]) {
      setState(() {
        if (nowIndex < widget.treasureID.length - 1) {
          nowIndex++; // 前進到下一個
        } else {
          _onAllFinished(); // 全部感應完成
        }
      });
    } else {
      // 錯誤處理：可以彈出 SnackBar 提示感應錯了
      ScaffoldMessenger.of(context).showSnackBar(
        //TODO 這裡也要重寫
        const SnackBar(content: Text("ID 不符合，請重新嘗試！")),
      );
    }
  }

  void _onAllFinished() {
    // 這裡處理最後的成功邏輯，例如 Navigator.push
    print("恭喜！所有流程已解鎖。");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              NfcButton(
                ans: widget.treasureID[nowIndex],
                onResult: _checkNfcResult,
              ),
            ],
          ),
        ), //TODO 隔離它並加上Text
      ),
    );
  }
}

//可變換NFCbutton實例化

class NfcButton extends StatefulWidget {
  final String ans;
  final Function(String id) onResult; // 成功感應後的動作
  const NfcButton({super.key, required this.ans, required this.onResult});
  @override
  State<StatefulWidget> createState() {
    return _NfcButton();
  }
}

class _NfcButton extends State<NfcButton> {
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
            // --- 成功：透過 .data 取得結果，並回傳 ID ---
            widget.onResult(response.data.tagId);
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
    debugPrint("NFC 掃描失敗: $errorType, 訊息: $message");

    // 在這裡根據錯誤類型彈出不同的 mes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // 設定停留時間，預設通常是 4 秒
        behavior: SnackBarBehavior.floating, // 讓它「浮起來」，看起來更現代
      ), //TODO 這裡也要重寫
    );
  }

  @override
  Widget build(BuildContext context) {
    return NfcButton1(
      text: _isScanning
          ? NfcLeadingStyle.primaryButtonString
          : NfcLeadingStyle.NfcIngString,
      onPressedToDo: onPressed,
      now_style: _isScanning
          ? NfcLeadingStyle.primaryButtonStyle
          : NfcLeadingStyle.NfcIngStyle,
    );
  }
}
