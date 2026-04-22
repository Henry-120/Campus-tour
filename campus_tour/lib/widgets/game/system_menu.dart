import 'package:flutter/material.dart';
import 'package:campus_tour/widgets/buttons/circle_icon_button.dart';
import 'package:campus_tour/view/encyclopedia_page.dart';
import '../../view/Camera_view.dart';
import '../../view/Real_ar_view.dart';
import '../../services/camera_service.dart';
import '../../styles/app_theme.dart';
import '../common/scale_button.dart';

class SystemMenu extends StatelessWidget {
  const SystemMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMenuButton(
          icon: Icons.auto_stories,
          label: 'Pokedex',
          onTap: () => _navigateTo(context, const EncyclopediaPage()),
        ),
        const SizedBox(width: 20),
        _buildScanButton(onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ArCapturePage(),
          ),
        ),
        ),
        const SizedBox(width: 20),
        _buildMenuButton(
          icon: Icons.local_mall,
          label: 'AR',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RealArPage (),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return ScaleButton(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Icon(icon, color: Colors.grey[700], size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton({required VoidCallback onTap}) {
    return ScaleButton(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor, // 橘黃色
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 4),
          const Text(
            'SCAN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}
