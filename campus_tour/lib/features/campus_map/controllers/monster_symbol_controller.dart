import 'dart:async';
import 'dart:ui' as ui;

import 'package:campus_tour/models/monster_model.dart';
import 'package:campus_tour/utils/monster_image_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MonsterSymbolController {
  MonsterSymbolController({required ValueChanged<MonsterModel> onMonsterTap})
    : _onMonsterTap = onMonsterTap;

  static const int _frameCount = 4;
  static const Duration _frameDuration = Duration(milliseconds: 300);
  static const int _imageSize = 300;
  static const double _iconSize = 0.5;
  static const int _zIndex = 100;
  static const String _iconAnchor = 'bottom';

  final ValueChanged<MonsterModel> _onMonsterTap;
  final Map<String, MonsterModel> _monstersById = {};
  final Map<String, Symbol> _symbolsByMonsterId = {}; //目前已經放在地圖上的 Symbol
  final Map<String, Uint8List> _preparedImageBytes = {}; //已由assest註冊進來的
  final Set<String> _registeredImageIds = {}; //已註冊進maplibre的imageId
  final Set<String> _missingAnimatedFolders = {}; //缺少的動畫資料夾
  final Set<String> _missingStaticImages = {}; //缺少的靜態圖片

  MapLibreMapController? _mapController;
  Timer? _animationTimer;
  Future<void>? _symbolSyncFuture;

  List<MonsterModel> _visibleMonsters = const [];
  int _frameIndex = 0;
  int _styleRevision = 0;
  int _monsterListRevision = 0;
  bool _attachedToCurrentStyle = false;
  bool _needsSymbolSync = false;
  bool _isDisposed = false;

  late final void Function(Symbol) _symbolTapListener = _handleSymbolTapped;

  void attachMapController(MapLibreMapController controller) {
    if (_isDisposed || identical(_mapController, controller)) return;

    _mapController?.onSymbolTapped.remove(_symbolTapListener);
    _mapController = controller;
    controller.onSymbolTapped
      ..remove(_symbolTapListener)
      ..add(_symbolTapListener);

    _attachedToCurrentStyle = false;
    _symbolsByMonsterId.clear();
    _registeredImageIds.clear();
    _needsSymbolSync = true;
  }

  Future<void> initialize() async {
    if (_isDisposed) return;

    final controller = _mapController;
    if (controller == null) {
      throw StateError('MonsterSymbolController 尚未取得 MapLibreMapController');
    }

    final styleRevision = _styleRevision;
    _attachedToCurrentStyle = true;
    if (_visibleMonsters.isNotEmpty) {
      _startAnimation();
    }

    try {
      await _requestSymbolSync();
    } catch (_) {
      final operationIsStale =
          _isDisposed ||
          styleRevision != _styleRevision ||
          !identical(controller, _mapController);
      if (operationIsStale) return;

      _attachedToCurrentStyle = false;
      rethrow;
    }
  }

  Future<void> setMonsters(Iterable<MonsterModel> monsters) async {
    if (_isDisposed) return;

    final monstersById = <String, MonsterModel>{};
    for (final monster in monsters) {
      if (monster.id.isNotEmpty) {
        monstersById[monster.id] = monster;
      }
    }

    _monsterListRevision++;
    _monstersById
      ..clear()
      ..addAll(monstersById);
    _visibleMonsters = List<MonsterModel>.unmodifiable(monstersById.values);

    if (_visibleMonsters.isEmpty) {
      _stopAnimation();
    } else if (_attachedToCurrentStyle) {
      _startAnimation();
    }

    await _requestSymbolSync();
  }

  //執行鎖
  Future<void> _requestSymbolSync() {
    if (_isDisposed || !_attachedToCurrentStyle) {
      return Future<void>.value();
    }

    _needsSymbolSync = true;
    return _symbolSyncFuture ??= _runSymbolSync();
  }

  Future<void> _runSymbolSync() async {
    try {
      while (_needsSymbolSync && !_isDisposed && _attachedToCurrentStyle) {
        _needsSymbolSync = false;
        await _syncSymbols();
      }
    } finally {
      _symbolSyncFuture = null;
    }
  }

  //被限定對象
  Future<void> _syncSymbols() async {
    final controller = _mapController;
    if (controller == null || !_attachedToCurrentStyle || _isDisposed) return;

    final styleRevision = _styleRevision; //版本鎖
    final monsterListRevision = _monsterListRevision; //持續移動會出問題嗎？
    final frameIndex = _frameIndex;
    final monsters = List<MonsterModel>.from(_visibleMonsters); //要準備被丟上地圖的
    final imageIdsByMonsterId = <String, String>{};
    //monsterId對應註冊進maplibre的現在這一禎的imageId
    //要準備被丟上地圖的

    for (final monster in monsters) {
      final imageId = await _prepareImagesAndGetCurrentFrameId(
        controller,
        monster,
        frameIndex, //CurrentFrameId
        styleRevision,
      );
      if (!_isCurrentOperation(controller, styleRevision)) return;
      if (monsterListRevision != _monsterListRevision) return;

      if (imageId != null) {
        imageIdsByMonsterId[monster.id] = imageId;
      }
    }

    final desiredMonsterIds = imageIdsByMonsterId.keys.toSet();
    for (final entry in _symbolsByMonsterId.entries.toList()) {
      if (desiredMonsterIds.contains(entry.key)) continue; //如果這個怪物還在要顯示的清單裡就跳過

      try {
        await controller.removeSymbol(entry.value); //舊的不在了就刪掉
      } catch (_) {
        if (!_isCurrentOperation(controller, styleRevision)) return;
        rethrow;
      }
      if (!_isCurrentOperation(controller, styleRevision)) return;
      _symbolsByMonsterId.remove(entry.key);
    }

    for (final monster in monsters) {
      final imageId = imageIdsByMonsterId[monster.id];
      if (imageId == null) continue;

      final options = SymbolOptions(
        geometry: LatLng(monster.location.latitude, monster.location.longitude),
        iconImage: imageId,
        iconSize: _iconSize,
        iconAnchor: _iconAnchor,
        zIndex: _zIndex,
      );
      final existingSymbol = _symbolsByMonsterId[monster.id];

      if (existingSymbol == null) {
        try {
          final symbol = await controller.addSymbol(options, {
            'monsterId': monster.id,
          });
          if (!_isCurrentOperation(controller, styleRevision)) return;
          _symbolsByMonsterId[monster.id] = symbol;
        } catch (_) {
          if (!_isCurrentOperation(controller, styleRevision)) return;
          rethrow;
        }
      } else {
        try {
          await controller.updateSymbol(existingSymbol, options);
        } catch (_) {
          if (!_isCurrentOperation(controller, styleRevision)) return;
          rethrow;
        }
        if (!_isCurrentOperation(controller, styleRevision)) return;
      }
    }
  }

  // _prepareImagesAndGetCurrentFrameId()
  // 先確保 frame1~frame4 都已註冊
  // 再根據 frameIndex 選一張
  // 回傳那一張的 imageId
  Future<String?> _prepareImagesAndGetCurrentFrameId(
    MapLibreMapController controller,
    MonsterModel monster,
    int frameIndex,
    int styleRevision,
  ) async {
    final animatedFolder = MonsterImagePath.fourPartsFolderName(
      monster.imageURL,
    );

    if (animatedFolder != null &&
        !_missingAnimatedFolders.contains(animatedFolder)) {
      final frames = <({String id, Uint8List bytes})>[];
      for (var frame = 1; frame <= _frameCount; frame++) {
        final path =
            'assets/images/fairy_four_parts/$animatedFolder/$frame.png';
        final bytes = await _prepareImage(path);
        if (bytes == null) {
          _missingAnimatedFolders.add(animatedFolder);
          frames.clear();
          break;
        }
        frames.add((id: _animatedImageId(animatedFolder, frame), bytes: bytes));
      }

      if (frames.isNotEmpty) {
        for (final frame in frames) {
          final registered = await _registerImage(
            //一禎一禎註冊進去
            controller,
            frame.id,
            frame.bytes,
            styleRevision,
          );
          if (!registered) return null; //如果一禎註冊失敗就不繼續了
        }
        return _animatedImageId(animatedFolder, frameIndex + 1);
      }
    }

    final staticPath = MonsterImagePath.staticImage(monster.imageURL);
    if (staticPath.isEmpty || _missingStaticImages.contains(staticPath)) {
      return null;
    }

    final staticBytes = await _prepareImage(staticPath);
    if (staticBytes == null) {
      _missingStaticImages.add(staticPath);
      return null;
    }

    final staticImageId = 'monster-${monster.id}-static';
    final registered = await _registerImage(
      controller,
      staticImageId,
      staticBytes,
      styleRevision,
    );
    return registered ? staticImageId : null;
  }

  Future<Uint8List?> _prepareImage(String path) async {
    final cachedBytes = _preparedImageBytes[path];
    if (cachedBytes != null) return cachedBytes;

    try {
      final byteData = await rootBundle.load(path);
      final resizedBytes = await _resizePng(byteData.buffer.asUint8List());
      if (!_isDisposed) {
        _preparedImageBytes[path] = resizedBytes;
      }
      return resizedBytes;
    } catch (error) {
      debugPrint('[MonsterSymbolController] 怪物圖片載入失敗：$path, $error');
      return null;
    }
  }

  Future<Uint8List> _resizePng(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _imageSize,
      targetHeight: _imageSize,
    );
    final frame = await codec.getNextFrame();

    try {
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw StateError('無法轉換怪物圖片');
      }
      return byteData.buffer.asUint8List();
    } finally {
      frame.image.dispose();
      codec.dispose();
    }
  }

  Future<bool> _registerImage(
    MapLibreMapController controller,
    String imageId,
    Uint8List bytes,
    int styleRevision,
  ) async {
    if (_registeredImageIds.contains(imageId)) return true;
    if (!_isCurrentOperation(controller, styleRevision)) return false;

    try {
      await controller.addImage(imageId, bytes);
    } catch (_) {
      if (!_isCurrentOperation(controller, styleRevision)) return false;
      rethrow;
    }

    if (!_isCurrentOperation(controller, styleRevision)) return false;
    _registeredImageIds.add(imageId);
    return true;
  }

  void _startAnimation() {
    if (_animationTimer?.isActive ?? false) return;

    _animationTimer = Timer.periodic(_frameDuration, (_) {
      if (_isDisposed || !_attachedToCurrentStyle) return;
      _frameIndex = (_frameIndex + 1) % _frameCount;
      unawaited(_requestSymbolSync());
    });
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
    _frameIndex = 0;
  }

  void _handleSymbolTapped(Symbol symbol) {
    if (_isDisposed) return;

    final monsterId = symbol.data?['monsterId'];
    if (monsterId is! String) return;

    final monster = _monstersById[monsterId];
    if (monster != null) {
      _onMonsterTap(monster);
    }
  }

  bool _isCurrentOperation(
    MapLibreMapController controller,
    int styleRevision,
  ) {
    return !_isDisposed &&
        _attachedToCurrentStyle &&
        styleRevision == _styleRevision &&
        identical(controller, _mapController);
  }

  static String _animatedImageId(String folder, int frame) {
    return 'monster-$folder-frame-$frame';
  }

  void resetAfterStyleReload() {
    if (_isDisposed) return;

    _styleRevision++;
    _attachedToCurrentStyle = false;
    _symbolsByMonsterId.clear();
    _registeredImageIds.clear();
    _needsSymbolSync = true;
  }

  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _styleRevision++;
    _animationTimer?.cancel();
    _animationTimer = null;
    _mapController?.onSymbolTapped.remove(_symbolTapListener);
    _mapController = null;
    _attachedToCurrentStyle = false;
    _needsSymbolSync = false;
    _visibleMonsters = const [];
    _monstersById.clear();
    _symbolsByMonsterId.clear();
    _registeredImageIds.clear();
    _preparedImageBytes.clear();
  }
}
