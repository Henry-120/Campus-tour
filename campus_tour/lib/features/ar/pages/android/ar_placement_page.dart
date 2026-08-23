import 'package:campus_tour/controllers/monster_controller.dart';
import 'package:campus_tour/features/ar/controllers/android/android_ar_scene_controller.dart';
import 'package:campus_tour/features/ar/models/ar_model_config.dart';
import 'package:campus_tour/features/ar/widgets/android/arcore_scene_view.dart';
import 'package:campus_tour/models/user_monster_model.dart';
import 'package:campus_tour/services/audio_service.dart';
import 'package:campus_tour/styles/app_theme.dart';
import 'package:campus_tour/utils/monster_image_path.dart';
import 'package:campus_tour/widgets/constants/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// ARCore placement page. Only models present in the Android GLB catalog are
/// offered; iOS-only USDZ references stay hidden on this platform.
class AndroidArPlacementPage extends StatefulWidget {
  const AndroidArPlacementPage({super.key});

  @override
  State<AndroidArPlacementPage> createState() => _AndroidArPlacementPageState();
}

class _AndroidArPlacementPageState extends State<AndroidArPlacementPage>
    with WidgetsBindingObserver {
  final AndroidArSceneController _sceneController = AndroidArSceneController();
  final MonsterController _monsterController = Get.find<MonsterController>();

  bool _sceneReady = false;
  bool _modelVisible = false;
  bool _planeDetected = false;
  bool _changingModel = false;
  String? _selectedArRef;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService().playOverlayBgm(fileName: 'audio/M12_AR_camera.flac');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService().pauseAllBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().resumeAllBgm();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AudioService().stopOverlayBgm();
    _sceneController.dispose();
    super.dispose();
  }

  Future<void> _selectMonster(UserMonsterModel monster) async {
    final arRef = monster.arRef?.trim();
    if (arRef == null || ArModelConfig.fromArRef(arRef) == null) return;

    setState(() {
      _selectedArRef = arRef;
      _modelVisible = false;
      _errorMessage = null;
    });
    if (_sceneReady) await _applySelectedModel();
  }

  Future<void> _applySelectedModel() async {
    final arRef = _selectedArRef;
    if (arRef == null || _changingModel) return;
    setState(() => _changingModel = true);
    try {
      final selected = await _sceneController.setModel(arRef);
      if (!mounted) return;
      setState(() {
        _changingModel = false;
        if (!selected) {
          _errorMessage = 'features.ar.pages.android.ar.placement.page.s001'.tr;
        }
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _changingModel = false;
        _errorMessage =
            error.message ??
            'features.ar.pages.android.ar.placement.page.s002'.tr;
      });
    }
  }

  Future<void> _clearModel() async {
    await _sceneController.clearModel();
    if (!mounted) return;
    setState(() => _modelVisible = false);
  }

  List<UserMonsterModel> _supportedMonsters(
    Iterable<UserMonsterModel> collection,
  ) {
    return collection
        .where((monster) => ArModelConfig.fromArRef(monster.arRef) != null)
        .toList(growable: false);
  }

  String get _statusMessage {
    if (_errorMessage != null) return _errorMessage!;
    if (_selectedArRef == null) {
      return 'features.ar.pages.android.ar.placement.page.s003'.tr;
    }
    if (_modelVisible) {
      return 'features.ar.pages.android.ar.placement.page.s004'.tr;
    }
    if (_planeDetected) {
      return 'features.ar.pages.android.ar.placement.page.s005'.tr;
    }
    return 'features.ar.pages.android.ar.placement.page.s006'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'view.real.ar.view.s001'.tr,
          style: AppTheme.emptyStateStyle(20 * scale),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ArCoreSceneView(
            controller: _sceneController,
            onReady: () async {
              if (!mounted) return;
              setState(() => _sceneReady = true);
              await _applySelectedModel();
            },
            onPlaneDetected: () {
              if (!mounted || _planeDetected) return;
              setState(() => _planeDetected = true);
            },
            onModelPlaced: () {
              if (!mounted) return;
              setState(() {
                _modelVisible = true;
                _errorMessage = null;
              });
            },
            onError: (message) {
              if (!mounted) return;
              setState(() {
                _errorMessage = message == 'MODEL_NOT_SELECTED'
                    ? 'features.ar.pages.android.ar.placement.page.s007'.tr
                    : 'features.ar.pages.android.ar.placement.page.s008'
                          .trParams({'message': message});
              });
            },
          ),
          if (_sceneReady &&
              _planeDetected &&
              !_modelVisible &&
              _selectedArRef != null)
            const IgnorePointer(
              child: Center(
                child: Icon(
                  Icons.add_circle_outline,
                  color: Colors.white70,
                  size: 42,
                ),
              ),
            ),
          if (!_sceneReady)
            ColoredBox(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'features.ar.pages.android.ar.placement.page.s009'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.all(16 * scale),
                padding: EdgeInsets.all(14 * scale),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scale,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    SizedBox(
                      height: 82 * scale,
                      child: Obx(() {
                        final monsters = _supportedMonsters(
                          _monsterController.userMonsterCollection,
                        );
                        if (monsters.isEmpty) {
                          return Center(
                            child: Text(
                              'features.ar.pages.android.ar.placement.page.s010'
                                  .tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        }
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: monsters.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(width: 12 * scale),
                          itemBuilder: (context, index) {
                            final monster = monsters[index];
                            final selected = _selectedArRef == monster.arRef;
                            return GestureDetector(
                              onTap: () => _selectMonster(monster),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 72 * scale,
                                padding: EdgeInsets.all(6 * scale),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.white12,
                                  borderRadius: BorderRadius.circular(
                                    14 * scale,
                                  ),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        MonsterImagePath.staticImage(
                                          monster.imageURL,
                                        ),
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.pets,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      monster.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10 * scale,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    if (_modelVisible) ...[
                      SizedBox(height: 8 * scale),
                      FilledButton.tonalIcon(
                        onPressed: _clearModel,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(
                          'features.ar.pages.android.ar.placement.page.s011'.tr,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
