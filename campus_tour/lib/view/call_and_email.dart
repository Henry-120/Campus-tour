import 'package:campus_tour/controllers/location_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CallAndEmailPage extends StatefulWidget {
  const CallAndEmailPage({super.key});

  @override
  State<CallAndEmailPage> createState() => _CallAndEmailPageState();
}

class _CallAndEmailPageState extends State<CallAndEmailPage> {
  static const String _healthCenterDirectPhone = '032804814';
  static const String _emergencySmsRecipient = '0911949630';
  static const MethodChannel _iosMessageChannel = MethodChannel(
    'tw.edu.ncu.campustour/message_compose',
  );

  String? _statusMessage;

  void _setStatus(String message) {
    if (!mounted) return;
    setState(() => _statusMessage = message);
  }

  Future<void> _composeEmergencySms() async {
    final description = await showDialog<String>(
      context: context,
      builder: (_) => const _EmergencyReportDialog(),
    );
    if (description == null || !mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final position = await Get.find<LocationController>().getCurrentPosition(
      fresh: true,
    );
    final locationText = position == null
        ? 'view.aed.map.s010'.tr
        : 'https://www.google.com/maps/search/?api=1&query='
              '${position.latitude},${position.longitude}';
    final body = 'view.aed.map.s014'.trParams({
      'description': description,
      'location': locationText,
      'timestamp': '${DateTime.now().toLocal()}',
    });

    final opened = await _openSmsComposer(body);
    if (!opened) {
      _setStatus(
        'view.aed.map.s021'.trParams({'phone': _emergencySmsRecipient}),
      );
    }
  }

  Future<bool> _openSmsComposer(String body) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        return await _iosMessageChannel.invokeMethod<bool>(
              'composeEmergencySms',
              <String, String>{
                'recipient': _emergencySmsRecipient,
                'body': body,
              },
            ) ??
            false;
      } on PlatformException {
        return false;
      }
    }

    final smsUri = Uri(
      scheme: 'sms',
      path: _emergencySmsRecipient,
      query: _encodeQueryParameters(<String, String>{'body': body}),
    );
    return launchUrl(smsUri, mode: LaunchMode.externalApplication);
  }

  String _encodeQueryParameters(Map<String, String> parameters) {
    return parameters.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}='
              '${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  Future<void> _callHealthCenter() async {
    final phoneUri = Uri(scheme: 'tel', path: _healthCenterDirectPhone);
    if (!await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
      _setStatus('view.aed.map.s017'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('view.call.and.email.s001'.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ContactActionButton(
                icon: Icons.call_rounded,
                label: 'view.aed.map.s020'.tr,
                color: const Color(0xFFB91C1C),
                onPressed: _callHealthCenter,
              ),
              const SizedBox(height: 18),
              _ContactActionButton(
                icon: Icons.sms_rounded,
                label: 'view.aed.map.s019'.tr,
                color: const Color(0xFF1D4ED8),
                onPressed: _composeEmergencySms,
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 24),
                Material(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  const _ContactActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label, textAlign: TextAlign.center),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _EmergencyReportDialog extends StatefulWidget {
  const _EmergencyReportDialog();

  @override
  State<_EmergencyReportDialog> createState() => _EmergencyReportDialogState();
}

class _EmergencyReportDialogState extends State<_EmergencyReportDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateSubmitState(String value) {
    final canSubmit = value.trim().isNotEmpty;
    if (canSubmit != _canSubmit) setState(() => _canSubmit = canSubmit);
  }

  void _submit() {
    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) Navigator.of(context).pop(description);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('view.aed.map.s006'.tr),
      content: TextField(
        controller: _descriptionController,
        minLines: 2,
        maxLines: 4,
        maxLength: 500,
        onChanged: _updateSubmitState,
        decoration: InputDecoration(
          hintText: 'view.aed.map.s007'.tr,
          counterText: '',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('view.aed.map.s008'.tr),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text('view.aed.map.s022'.tr),
        ),
      ],
    );
  }
}
