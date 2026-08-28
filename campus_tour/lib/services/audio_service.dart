import 'package:audioplayers/audioplayers.dart';
import '../local_information/local_setting.dart';
import 'pad_audio_service.dart';
import 'dart:io';

enum AudioTrack {
  login('M01_login'),
  settings('M02_settings'),
  tutorial('M03_tutorial'),
  walkDaytime('M04_walk_daytime'),
  walkNight('M05_walk_night'),
  findMonster('M06_find_monster'),
  opening('M07_opening'),
  qaTime('M08_qa_time'),
  catchSuccess('M09_catch_success'),
  catchFail('M10_catch_fail'),
  encyclopedia('M11_encyclopedia'),
  arCamera('M12_AR_camera'),
  finalStageBpm130('M13_final_stage_BPM130'),
  finalStageBpm135('M13_final_stage_BPM135');

  const AudioTrack(this.baseName);

  final String baseName;

  String get androidAssetPath => 'music/$baseName.flac';
  String get iosAssetPath => 'audio/$baseName.m4a';
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // 💡 三個播放器：主 BGM、子頁面 BGM、音效
  final AudioPlayer _mainBgmPlayer = AudioPlayer();
  final AudioPlayer _overlayBgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _masterVolume = 1.0;
  double _mainBgmGain = 1.0;
  double _overlayBgmGain = 1.0;
  double _sfxGain = 1.0;

  // 記錄目前 mainBgm 播的是哪一首，避免同一首被重播從頭
  AudioTrack? _currentMainBgmTrack;

  bool _isOverlayActive = false;
  bool _isBgmSuppressedForSfx = false;

  double _normalizeVolume(double volume) => volume.clamp(0.0, 1.0).toDouble();

  Future<void> initializeVolume() async {
    await setMasterVolume(LocalSettingService.volume.ratio);
  }

  Future<void> setMasterVolume(double volume) async {
    _masterVolume = _normalizeVolume(volume);

    await Future.wait([
      _mainBgmPlayer.setVolume(_mainBgmGain * _masterVolume),
      _overlayBgmPlayer.setVolume(_overlayBgmGain * _masterVolume),
      _sfxPlayer.setVolume(_sfxGain * _masterVolume),
    ]);
  }

  Future<Source> _getSource(AudioTrack track) {
    if (Platform.isAndroid) {
      return PadAudioService.getSource(track.androidAssetPath);
    }

    if (Platform.isIOS) {
      return Future<Source>.value(AssetSource(track.iosAssetPath));
    }

    return Future<Source>.error(
      UnsupportedError('Audio playback is only configured for Android and iOS'),
    );
  }

  // ── 主 BGM（例如 GameMainPage 的 walk_daytime）──────────────────────
  //   進入主畫面呼叫 playMainBgm，可以持續播放。
  //   打開子頁面時 pauseMainBgm，回來時 resumeMainBgm，播放位置會延續。

  Future<void> playMainBgm({
    required AudioTrack track,
    double volume = 1.0,
    double playbackRate = 1.0,
  }) async {
    _mainBgmGain = _normalizeVolume(volume);

    // 如果已經在播同一首，就不重設 source，直接 resume
    if (_currentMainBgmTrack == track) {
      await _mainBgmPlayer.setVolume(_mainBgmGain * _masterVolume);
      if (!_isBgmSuppressedForSfx) {
        await _mainBgmPlayer.resume();
      }
      return;
    }
    _currentMainBgmTrack = track;
    await _mainBgmPlayer.setSource(await _getSource(track));

    _mainBgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _mainBgmPlayer.setVolume(_mainBgmGain * _masterVolume);
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

  Future<void> stopMainBgm({AudioTrack? onlyIfPlaying}) async {
    if (onlyIfPlaying != null && _currentMainBgmTrack != onlyIfPlaying) {
      return;
    }
    await _mainBgmPlayer.stop();
    _currentMainBgmTrack = null;
  }

  // ── 子頁面 BGM（例如圖鑑、AR 相機）────────────────────────────────
  //   進來播、離開停，不會影響主 BGM 的播放位置。

  Future<void> playOverlayBgm({
    required AudioTrack track,
    double volume = 1.0,
    bool isLooping = true,
    double playbackRate = 1.0,
  }) async {
    _overlayBgmGain = _normalizeVolume(volume);
    _isOverlayActive = true;
    await _overlayBgmPlayer.setSource(await _getSource(track));

    _overlayBgmPlayer.setReleaseMode(
      isLooping ? ReleaseMode.loop : ReleaseMode.release,
    );
    await _overlayBgmPlayer.setVolume(_overlayBgmGain * _masterVolume);
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
    required AudioTrack track,
    double volume = 1.0,
    bool pauseBgmUntilComplete = false,
    Function? onComplete,
  }) async {
    _sfxGain = _normalizeVolume(volume);

    if (pauseBgmUntilComplete) {
      _isBgmSuppressedForSfx = true;
      await pauseAllBgm();
    }

    try {
      await _sfxPlayer.setSource(await _getSource(track));
      _sfxPlayer.setReleaseMode(ReleaseMode.release);
      await _sfxPlayer.setVolume(_sfxGain * _masterVolume);

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
    _currentMainBgmTrack = null;
    _isOverlayActive = false;
    _isBgmSuppressedForSfx = false;
  }
}
