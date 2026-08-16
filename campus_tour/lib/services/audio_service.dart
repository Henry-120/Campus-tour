import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // 💡 三個播放器：主 BGM、子頁面 BGM、音效
  final AudioPlayer _mainBgmPlayer = AudioPlayer();
  final AudioPlayer _overlayBgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // 記錄目前 mainBgm 播的是哪一首，避免同一首被重播從頭
  String? _currentMainBgmFile;

  bool _isOverlayActive = false;
  bool _isBgmSuppressedForSfx = false;

  // ── 主 BGM（例如 GameMainPage 的 walk_daytime）──────────────────────
  //   進入主畫面呼叫 playMainBgm，可以持續播放。
  //   打開子頁面時 pauseMainBgm，回來時 resumeMainBgm，播放位置會延續。

  Future<void> playMainBgm({
    required String fileName,
    double volume = 1.0,
    double playbackRate = 1.0,
  }) async {
    // 如果已經在播同一首，就不重設 source，直接 resume
    if (_currentMainBgmFile == fileName) {
      if (!_isBgmSuppressedForSfx) {
        await _mainBgmPlayer.resume();
      }
      return;
    }
    _currentMainBgmFile = fileName;
    await _mainBgmPlayer.setSource(AssetSource(fileName));
    _mainBgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _mainBgmPlayer.setVolume(volume);
    await _mainBgmPlayer.setPlaybackRate(playbackRate);
    if (!_isBgmSuppressedForSfx) {
      await _mainBgmPlayer.resume();
    }
  }

  Future<void> pauseMainBgm() async => await _mainBgmPlayer.pause();
  Future<void> resumeMainBgm() async {
    if (!_isBgmSuppressedForSfx) {
      await _mainBgmPlayer.resume();
    }
  }

  Future<void> stopMainBgm({String? onlyIfPlaying}) async {
    if (onlyIfPlaying != null && _currentMainBgmFile != onlyIfPlaying) {
      return;
    }
    await _mainBgmPlayer.stop();
    _currentMainBgmFile = null;
  }

  // ── 子頁面 BGM（例如圖鑑、AR 相機）────────────────────────────────
  //   進來播、離開停，不會影響主 BGM 的播放位置。

  Future<void> playOverlayBgm({
    required String fileName,
    double volume = 1.0,
    bool isLooping = true,
    double playbackRate = 1.0,
  }) async {
    _isOverlayActive = true;
    await _overlayBgmPlayer.setSource(AssetSource(fileName));
    _overlayBgmPlayer.setReleaseMode(
      isLooping ? ReleaseMode.loop : ReleaseMode.release,
    );
    await _overlayBgmPlayer.setVolume(volume);
    await _overlayBgmPlayer.setPlaybackRate(playbackRate);
    if (!_isBgmSuppressedForSfx) {
      await _overlayBgmPlayer.resume();
    }
  }

  Future<void> pauseOverlayBgm() async => await _overlayBgmPlayer.pause();
  Future<void> resumeOverlayBgm() async => await _overlayBgmPlayer.resume();
  Future<void> stopOverlayBgm() async {
    _isOverlayActive = false;
    await _overlayBgmPlayer.stop();
  }

  // ── 音效（一次性，如捕捉成功、失敗音效）──────────────────────────

  Future<void> playSfx({
    required String fileName,
    double volume = 1.0,
    bool pauseBgmUntilComplete = false,
    Function? onComplete,
  }) async {
    if (pauseBgmUntilComplete) {
      _isBgmSuppressedForSfx = true;
      await pauseAllBgm();
    }

    try {
      await _sfxPlayer.setSource(AssetSource(fileName));
      _sfxPlayer.setReleaseMode(ReleaseMode.release);
      await _sfxPlayer.setVolume(volume);

      final completed = _sfxPlayer.onPlayerComplete.first;
      await _sfxPlayer.resume();

      if (pauseBgmUntilComplete) {
        await completed;
        onComplete?.call();
      } else if (onComplete != null) {
        completed.then((_) => onComplete());
      }
    } finally {
      if (pauseBgmUntilComplete) {
        _isBgmSuppressedForSfx = false;
        await resumeAllBgm();
      }
    }
  }

  // ── 綜合控制 ──────────────────────────────────────────────────────

  /// 暫停所有 BGM（app 進入背景時呼叫）
  Future<void> pauseAllBgm() async {
    await _mainBgmPlayer.pause();
    await _overlayBgmPlayer.pause();
  }

  /// 恢復所有 BGM（app 回到前景時呼叫）
  Future<void> resumeAllBgm() async {
    if (_isBgmSuppressedForSfx) return;

    if (_isOverlayActive) {
      await _overlayBgmPlayer.resume();
    } else {
      await _mainBgmPlayer.resume();
    }
  }

  /// 完全停止所有音訊（例如登出）
  Future<void> stopAll() async {
    await _mainBgmPlayer.stop();
    await _overlayBgmPlayer.stop();
    await _sfxPlayer.stop();
    _currentMainBgmFile = null;
    _isOverlayActive = false;
    _isBgmSuppressedForSfx = false;
  }
}
