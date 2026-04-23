import 'package:hive_flutter/hive_flutter.dart';

class LocalSettingService {
  LocalSettingService._();

  static const String _boxName = 'local_settings';
  static late final Box<dynamic> _box;
  static bool _isInitialized = false;
  static Future<void>? _initFuture;

  static final VolumeSetting volume = VolumeSetting._();
  static final VibrationSetting vibration = VibrationSetting._();

  static Future<void> initBox() {
    if (_isInitialized) {
      return Future.value();
    }

    return _initFuture ??= _initialize();
  }

  static Future<void> _initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);

    await volume.ensureInitialized(_box);
    await vibration.ensureInitialized(_box);

    _isInitialized = true;
  }

  static Box<dynamic> get settingsBox {
    if (!_isInitialized) {
      throw StateError(
        'LocalSettingService.initBox() must be called before using settings.',
      );
    }

    return _box;
  }
}

abstract class LocalSettingItem<T> {
  const LocalSettingItem(this.key, this.defaultValue);

  final String key;
  final T defaultValue;

  Box<dynamic> get _box => LocalSettingService.settingsBox;

  Future<void> ensureInitialized(Box<dynamic> box) async {
    if (!box.containsKey(key)) {
      await box.put(key, normalize(defaultValue));
    }
  }

  T getValue() {
    final dynamic rawValue = _box.get(key);
    if (rawValue == null) {
      return normalize(defaultValue);
    }

    return read(rawValue);
  }

  Future<void> setValue(T value) async {
    await _box.put(key, normalize(value));
  }

  Future<void> reset() => setValue(defaultValue);

  T read(dynamic rawValue);

  T normalize(T value);
}

class VolumeSetting extends LocalSettingItem<int> {
  VolumeSetting._() : super(_key, 100);

  static const String _key = 'volume';

  int get current => getValue();

  double get ratio => current / 100;

  Future<void> update(int value) => setValue(value);

  @override
  int read(dynamic rawValue) {
    if (rawValue is int) {
      return normalize(rawValue);
    }

    if (rawValue is num) {
      return normalize(rawValue.round());
    }

    return defaultValue;
  }

  @override
  int normalize(int value) => value.clamp(0, 100).toInt();
}

class VibrationSetting extends LocalSettingItem<bool> {
  VibrationSetting._() : super(_key, true);

  static const String _key = 'vibration_enabled';

  bool get isEnabled => getValue();

  Future<void> update(bool enabled) => setValue(enabled);

  Future<void> enable() => setValue(true);

  Future<void> disable() => setValue(false);

  Future<void> toggle() => setValue(!isEnabled);

  @override
  bool read(dynamic rawValue) {
    if (rawValue is bool) {
      return rawValue;
    }

    return defaultValue;
  }

  @override
  bool normalize(bool value) => value;
}
