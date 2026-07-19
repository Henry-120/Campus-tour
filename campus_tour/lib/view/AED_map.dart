import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AEDMap extends StatefulWidget {
  const AEDMap({super.key});

  @override
  State<AEDMap> createState() => _AEDMapState();
}

class _AEDMapState extends State<AEDMap> {
  static const String _healthCenterEmail = 'henry12081017@gmail.com';
  static const String _healthCenterDirectPhone = '032804814';
  static const String _campusMapAssetPath =
      'assets/images/Disaster_Evacuation_Map/防災地圖_地圖.jpg';

  static const Size _mapImageSize = Size(7734, 5243);
  static const double _topLatitude = 24.972389;
  static const double _bottomLatitude = 24.963905;
  static const double _leftLongitude = 121.184551;
  static const double _rightLongitude = 121.198360;
  static const List<DeviceOrientation> _landscapeOrientations = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
  static const List<DeviceOrientation> _restoreOrientations = [
    DeviceOrientation.portraitUp,
  ];

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Position? _currentPosition;
  double? _heading;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _lockLandscape();
    _startLocationTracking();
    _startCompassTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _compassSubscription?.cancel();
    _restoreOrientation();
    super.dispose();
  }

  Future<void> _lockLandscape() async {
    await SystemChrome.setPreferredOrientations(_landscapeOrientations);
  }

  Future<void> _restoreOrientation() async {
    await SystemChrome.setPreferredOrientations(_restoreOrientations);
  }

  Future<void> _startLocationTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setStatus('view.aed.map.s001'.tr);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _setStatus('view.aed.map.s002'.tr);
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      _setStatus('view.aed.map.s003'.tr);
      return;
    }

    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = initialPosition;
        _statusMessage = null;
      });
    } catch (error) {
      _setStatus('view.aed.map.s004'.trParams({'error': '$error'}));
    }

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 1,
          ),
        ).listen(
          (position) {
            if (!mounted) return;
            setState(() {
              _currentPosition = position;
              _statusMessage = null;
            });
          },
          onError: (error) {
            _setStatus('view.aed.map.s005'.trParams({'error': '$error'}));
          },
        );
  }

  void _startCompassTracking() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null || !mounted) return;

      setState(() {
        _heading = heading;
      });
    });
  }

  void _setStatus(String message) {
    if (!mounted) return;

    setState(() {
      _statusMessage = message;
    });
  }

  Future<void> _composeEmergencyEmail() async {
    final description = await showDialog<String>(
      context: context,
      builder: (_) => const _EmergencyReportDialog(),
    );

    if (description == null || !mounted) return;

    // Allow the dialog's reverse transition and inherited dependencies to
    // detach before the app is paused by the external email application.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final position = await _positionForReport();
    final locationText = position == null
        ? 'view.aed.map.s010'.tr
        : '${'view.aed.map.s011'.tr}：${position.latitude}\n'
              '${'view.aed.map.s012'.tr}：${position.longitude}\n'
              '${'view.aed.map.s013'.tr}：https://www.google.com/maps/search/?api=1&query='
              '${position.latitude},${position.longitude}';
    final timestamp = DateTime.now().toLocal();
    final body = 'view.aed.map.s014'.trParams({
      'description': description,
      'location': locationText,
      'timestamp': '$timestamp',
    });
    final emailUri = Uri(
      scheme: 'mailto',
      path: _healthCenterEmail,
      queryParameters: {'subject': 'view.aed.map.s015'.tr, 'body': body},
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      _setStatus('view.aed.map.s016'.trParams({'email': _healthCenterEmail}));
    }
  }

  Future<Position?> _positionForReport() async {
    if (_currentPosition != null) return _currentPosition;

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _callHealthCenter() async {
    final phoneUri = Uri(scheme: 'tel', path: _healthCenterDirectPhone);
    if (!await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
      _setStatus('view.aed.map.s017'.tr);
    }
  }

  Rect _containedMapRect(Size containerSize) {
    final widthScale = containerSize.width / _mapImageSize.width;
    final heightScale = containerSize.height / _mapImageSize.height;
    final scale = widthScale < heightScale ? widthScale : heightScale;
    final width = _mapImageSize.width * scale;
    final height = _mapImageSize.height * scale;

    return Rect.fromLTWH(
      (containerSize.width - width) / 2,
      (containerSize.height - height) / 2,
      width,
      height,
    );
  }

  Offset? _positionOffset(Rect mapRect) {
    final position = _currentPosition;
    if (position == null) return null;

    final longitudeRatio =
        (position.longitude - _leftLongitude) /
        (_rightLongitude - _leftLongitude);
    final latitudeRatio =
        (_topLatitude - position.latitude) / (_topLatitude - _bottomLatitude);

    if (longitudeRatio < 0 ||
        longitudeRatio > 1 ||
        latitudeRatio < 0 ||
        latitudeRatio > 1) {
      return null;
    }

    return Offset(
      mapRect.left + mapRect.width * longitudeRatio,
      mapRect.top + mapRect.height * latitudeRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                boundaryMargin: const EdgeInsets.all(96),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final mapRect = _containedMapRect(viewportSize);
                    final playerOffset = _positionOffset(mapRect);

                    return SizedBox(
                      width: viewportSize.width,
                      height: viewportSize.height,
                      child: Stack(
                        children: [
                          Positioned.fromRect(
                            rect: mapRect,
                            child: Image.asset(
                              _campusMapAssetPath,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return ColoredBox(
                                  color: Colors.white,
                                  child: Center(
                                    child: Text(
                                      'view.aed.map.s018'.trParams({
                                        'error': '$error',
                                      }),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (playerOffset != null)
                            Positioned(
                              left: playerOffset.dx - 18,
                              top: playerOffset.dy - 18,
                              child: Transform.rotate(
                                angle: ((_heading ?? 0) * 3.1415926535) / 180,
                                child: const Icon(
                                  Icons.navigation,
                                  color: Color(0xFFE11D48),
                                  size: 36,
                                  shadows: [
                                    Shadow(color: Colors.white, blurRadius: 6),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EmergencyActionButton(
                    tooltip: 'view.aed.map.s019'.tr,
                    icon: Icons.email_rounded,
                    onPressed: _composeEmergencyEmail,
                  ),
                  const SizedBox(width: 10),
                  _EmergencyActionButton(
                    tooltip: 'view.aed.map.s020'.tr,
                    icon: Icons.call_rounded,
                    backgroundColor: Color(0xFFB91C1C),
                    onPressed: _callHealthCenter,
                  ),
                ],
              ),
            ),
            if (_statusMessage != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Material(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyActionButton extends StatelessWidget {
  const _EmergencyActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF1D4ED8),
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
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
    if (canSubmit == _canSubmit) return;
    setState(() => _canSubmit = canSubmit);
  }

  void _submit() {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) return;
    Navigator.of(context).pop(description);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      title: Text('view.aed.map.s006'.tr),
      content: TextField(
        controller: _descriptionController,
        minLines: 2,
        maxLines: 4,
        maxLength: 500,
        textInputAction: TextInputAction.newline,
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
          child: Text('view.aed.map.s009'.tr),
        ),
      ],
    );
  }
}
