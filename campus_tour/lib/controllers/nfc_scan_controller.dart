import 'package:campus_tour/controllers/nfc_api.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NfcScanController extends GetxController {
  bool _isListening = false;
  bool _isWaiting = false;
  String? _expectedId;
  VoidCallback? _onSuccess;
  void Function(String scannedId)? _onMismatch;
  void Function(NfcErrorType errorType, {String? message})? _onError;

  bool get isListening => _isListening;
  bool get isWaiting => _isWaiting;

  Future<void> startForegroundListening() async {
    if (_isListening) return;

    final response = await NFCservice.startForegroundListening(
      onTag: _handleTag,
      onError: (errorType, {message}) {
        _isListening = false;
        _onError?.call(errorType, message: message);
      },
    );

    if (response != null && !response.isSuccess) {
      _onError?.call(response.error, message: response.errorMessage);
      return;
    }

    _isListening = true;
  }

  Future<void> stopForegroundListening() async {
    if (!_isListening) return;

    stopWaiting();
    _isListening = false;
    await NFCservice.stopScanning();
  }

  void startWaiting({
    required String expectedId,
    required VoidCallback onSuccess,
    required void Function(String scannedId) onMismatch,
    void Function(NfcErrorType errorType, {String? message})? onError,
  }) {
    _isWaiting = true;
    _expectedId = expectedId;
    _onSuccess = onSuccess;
    _onMismatch = onMismatch;
    _onError = onError;
  }

  void stopWaiting() {
    _isWaiting = false;
    _expectedId = null;
    _onSuccess = null;
    _onMismatch = null;
    _onError = null;
  }

  void _handleTag(NfcScanResult result) {
    if (!_isWaiting) {
      debugPrint('[Debug][NFC]:冷處理 NFC ${result.tagId}');
      return;
    }

    if (result.tagId == _expectedId) {
      final onSuccess = _onSuccess;
      stopWaiting();
      onSuccess?.call();
      return;
    }

    _onMismatch?.call(result.tagId);
  }

  @override
  void onClose() {
    stopForegroundListening();
    super.onClose();
  }
}
