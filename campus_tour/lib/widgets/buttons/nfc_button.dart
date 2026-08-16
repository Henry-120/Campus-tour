import 'dart:async';

import 'package:campus_tour/controllers/nfc_api.dart';
import 'package:campus_tour/controllers/nfc_scan_controller.dart';
import 'package:flutter/material.dart';
import 'package:campus_tour/styles/nfc_leading_style.dart';
import 'package:campus_tour/widgets/common/snackbar_builder.dart';
import 'package:get/get.dart';

import '../../controllers/reviewer_access_controller.dart';

class NfcButtonAbstract extends StatelessWidget {
  final Icon nfcIcon = NfcLeadingStyle.nfcIcon;
  final String text;
  final VoidCallback onPressedToDo;
  final ButtonStyle nowStyle;

  NfcButtonAbstract({
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
  bool _isUsingForegroundWaiting = false;
  late final NfcScanController _nfcScanController;

  @override
  void initState() {
    super.initState();
    _nfcScanController = Get.find<NfcScanController>();
  }

  Future<void> onPressed() async {
    if (_isScanning) {
      if (_isUsingForegroundWaiting) {
        _nfcScanController.stopWaiting();
      } else {
        await NFCservice.stopScanning();
      }
      _isUsingForegroundWaiting = false;
      setState(() => _isScanning = false);
      return;
    }

    if (!_nfcScanController.isListening) {
      await _scanSingleTagFallback();
      return;
    }

    setState(() => _isScanning = true);
    _isUsingForegroundWaiting = true;

    _nfcScanController.startWaiting(
      expectedId: widget.ans,
      onSuccess: () {
        if (!mounted) return;
        _isUsingForegroundWaiting = false;
        setState(() => _isScanning = false);
        widget.onResult();
      },
      onMismatch: (_) {
        if (!mounted) return;
        SnackBarBuilder.show(
          context,
          'widgets.buttons.nfc.button.s001'.tr,
          type: AppToastType.warning,
        );
      },
      onError: (errorType, {message}) {
        if (!mounted) return;
        _isUsingForegroundWaiting = false;
        setState(() => _isScanning = false);
        _handleError(errorType);
      },
    );
  }

  Future<void> _scanSingleTagFallback() async {
    _isUsingForegroundWaiting = false;
    setState(() => _isScanning = true);

    try {
      final response = await NFCservice.scanSingleTag();
      if (response == null) throw StateError("Undefult Error return Error");

      if (!mounted || !_isScanning) return;

      if (response.isSuccess) {
        final tagId = response.data.tagId;
        if (tagId == widget.ans) {
          widget.onResult();
        } else {
          SnackBarBuilder.show(
            context,
            'widgets.buttons.nfc.button.s001'.tr,
            type: AppToastType.warning,
          );
        }
      } else {
        _handleError(response.error);
      }
    } catch (e) {
      debugPrint("系統層級錯誤: $e");
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _simulateReviewerTag() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _isUsingForegroundWaiting = true;
    });
    _nfcScanController.startWaiting(
      expectedId: widget.ans,
      onSuccess: () {
        if (!mounted) return;
        _isUsingForegroundWaiting = false;
        setState(() => _isScanning = false);
        widget.onResult();
      },
      onMismatch: (_) {},
    );

    if (!_nfcScanController.simulateExpectedTagForReviewer() && mounted) {
      _nfcScanController.stopWaiting();
      _isUsingForegroundWaiting = false;
      setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    if (_isScanning) {
      if (_isUsingForegroundWaiting) {
        _nfcScanController.stopWaiting();
      } else {
        unawaited(NFCservice.stopScanning());
      }
    }
    super.dispose();
  }

  void _handleError(NfcErrorType errorType) {
    String message;
    switch (errorType) {
      case NfcErrorType.userCanceled:
        message = 'widgets.buttons.nfc.button.s003'.tr;
        break;

      case NfcErrorType.hardwareDisabled:
        //_showOpenSettingsDialog(); // 彈出視窗叫使用者去開 NFC
        message = 'widgets.buttons.nfc.button.s004'.tr;
        break;

      case NfcErrorType.parseFailed:
        message = 'widgets.buttons.nfc.button.s005'.tr;
        break;

      default:
        debugPrint('widgets.buttons.nfc.button.s006'.tr);
        message = 'widgets.buttons.nfc.button.s006'.tr;
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
    final reviewerAccess = Get.find<ReviewerAccessController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NfcButtonAbstract(
          text: _isScanning
              ? NfcLeadingStyle.nfcIngString
              : NfcLeadingStyle.primaryButtonString,
          onPressedToDo: onPressed,
          nowStyle: _isScanning
              ? NfcLeadingStyle.nfcIngStyle
              : NfcLeadingStyle.primaryButtonStyle,
        ),
        Obx(
          () => reviewerAccess.isReviewer.value
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FilledButton.icon(
                    onPressed: _isScanning ? null : _simulateReviewerTag,
                    icon: const Icon(Icons.developer_mode_rounded),
                    label: Text('widgets.buttons.nfc.button.s007'.tr),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
