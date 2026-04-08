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

  void _checkNfcResult(NfcScanResult result) {
    // 檢查感應到的 ID 是否符合目前進度要求的 ID
    String scannedId = result.tagId;
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
        //TODO 這裡也要重寫  //解決訊息過多的問題
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
              Text(
                widget.treasureText[nowIndex],
                style: NfcLeadingStyle.mission_style,
              ),
              NfcButton1(
                ans: widget.treasureID[nowIndex],
                onResult: _checkNfcResult,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
