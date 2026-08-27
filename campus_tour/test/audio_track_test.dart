import 'dart:io';

import 'package:campus_tour/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every audio track resolves to the platform-specific format', () {
    const expectedBaseNames = <AudioTrack, String>{
      AudioTrack.login: 'M01_login',
      AudioTrack.settings: 'M02_settings',
      AudioTrack.tutorial: 'M03_tutorial',
      AudioTrack.walkDaytime: 'M04_walk_daytime',
      AudioTrack.walkNight: 'M05_walk_night',
      AudioTrack.findMonster: 'M06_find_monster',
      AudioTrack.opening: 'M07_opening',
      AudioTrack.qaTime: 'M08_qa_time',
      AudioTrack.catchSuccess: 'M09_catch_success',
      AudioTrack.catchFail: 'M10_catch_fail',
      AudioTrack.encyclopedia: 'M11_encyclopedia',
      AudioTrack.arCamera: 'M12_AR_camera',
      AudioTrack.finalStageBpm130: 'M13_final_stage_BPM130',
      AudioTrack.finalStageBpm135: 'M13_final_stage_BPM135',
    };

    expect(AudioTrack.values, hasLength(expectedBaseNames.length));
    for (final entry in expectedBaseNames.entries) {
      expect(entry.key.baseName, entry.value);
      expect(entry.key.androidAssetPath, 'music/${entry.value}.flac');
      expect(entry.key.iosAssetPath, 'audio/${entry.value}.m4a');
    }
  });

  test('every track has exactly the expected platform assets', () {
    for (final track in AudioTrack.values) {
      expect(
        File(
          'android/music_pack/src/main/assets/${track.androidAssetPath}',
        ).existsSync(),
        isTrue,
        reason: 'Missing Android FLAC for ${track.name}',
      );
      expect(
        File('assets/${track.iosAssetPath}').existsSync(),
        isTrue,
        reason: 'Missing iOS M4A for ${track.name}',
      );
    }

    final iosFlacFiles = Directory(
      'assets/audio',
    ).listSync().whereType<File>().where((file) => file.path.endsWith('.flac'));
    final androidM4aFiles = Directory(
      'android/music_pack/src/main/assets/music',
    ).listSync().whereType<File>().where((file) => file.path.endsWith('.m4a'));

    expect(iosFlacFiles, isEmpty);
    expect(androidM4aFiles, isEmpty);
  });
}
