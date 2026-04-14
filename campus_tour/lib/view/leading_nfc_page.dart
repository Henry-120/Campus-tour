import 'package:campus_tour/styles/nfc_leading_style.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/widgets/buttons/nfc_button.dart';

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

  void _onMatched() {
    // Called when the NfcButton confirms a match for the current treasure id.
    setState(() {
      if (nowIndex < widget.treasureID.length - 1) {
        nowIndex++; // 前進到下一個
      } else {
        _onAllFinished(); // 全部感應完成
      }
    });
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
                onResult: _onMatched,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
