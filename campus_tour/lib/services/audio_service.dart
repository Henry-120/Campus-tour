import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // 💡 準備兩個播放器：一個給背景音樂，一個給特效
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  /// 播放功能
  Future<void> play({
    required String fileName,
    bool isBgm = false,         // 💡 新增參數：是否為背景音樂
    double volume = 1.0,
    bool isLooping = false,
    double playbackRate = 1.0,
    Function? onComplete,
  }) async {
    // 根據類型選擇播放器
    final player = isBgm ? _bgmPlayer : _sfxPlayer;

    await player.setSource(AssetSource(fileName));
    
    // 設定循環與釋放模式
    player.setReleaseMode(isLooping ? ReleaseMode.loop : ReleaseMode.release);

    await player.setVolume(volume);
    await player.setPlaybackRate(playbackRate);

    // 監聽完成事件
    if (onComplete != null) {
      player.onPlayerComplete.first.then((_) => onComplete());
    }

    await player.resume();
  }

  // 💡 新增控制方法給 BGM 使用
  Future<void> pauseBgm() async => await _bgmPlayer.pause();
  Future<void> resumeBgm() async => await _bgmPlayer.resume();
  Future<void> stopAll() async {
    await _bgmPlayer.stop();
    await _sfxPlayer.stop();
  }
}