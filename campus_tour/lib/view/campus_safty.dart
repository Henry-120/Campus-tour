import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/view/aed_map.dart';
import 'package:campus_tour/view/call_and_email.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampusSafetyPage extends StatelessWidget {
  const CampusSafetyPage({super.key});

  void _openEmergencyMap(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AEDMap()));
  }

  void _openCallAndReport(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CallAndEmailPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('view.campus.safety.s001'.tr)),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7FAFC), Color(0xFFE8F3F5)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SafetyActionButton(
                    icon: Icons.emergency_rounded,
                    label: 'view.campus.safety.s002'.tr,
                    onPressed: () => _openEmergencyMap(context),
                  ),
                  const SizedBox(height: 18),
                  _SafetyActionButton(
                    icon: Icons.contact_emergency_rounded,
                    label: 'view.campus.safety.s003'.tr,
                    onPressed: () => _openCallAndReport(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyActionButton extends StatelessWidget {
  const _SafetyActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
