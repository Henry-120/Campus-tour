import 'package:hive_flutter/hive_flutter.dart';

class LocalSettingService {
  LocalSettingService._();

  static const String _boxName = 'local_settings';
  static late final Box<dynamic> _box;
  static bool _isInitialized = false; //初始化完成否
  static Future<void>? _initFuture; //是否正在執行初始化

  static final VolumeSetting volume = VolumeSetting._();
  static final VibrationSetting vibration = VibrationSetting._();
  static final AutoSkipStorySetting autoSkipStory = AutoSkipStorySetting._();
  static final LanguageSetting language = LanguageSetting._();

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
    await autoSkipStory.ensureInitialized(_box);
    await language.ensureInitialized(_box);

    _isInitialized = true;
  } //初始化過程並隱式回傳Future<void>

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

  Box<dynamic> get _box => LocalSettingService.settingsBox; //取得Box本身

  Future<void> ensureInitialized(Box<dynamic> box) async {
    //初始化設定項目：如果Box中沒有對應的key，則放入預設值
    if (!box.containsKey(key)) {
      await box.put(key, normalize(defaultValue));
    }
  }

  T getValue() {
    //取得設定值：從Box中讀取對應key的值，進行正常化檢查
    final dynamic rawValue = _box.get(key);
    if (rawValue == null) {
      return normalize(defaultValue);
    }

    return _read(rawValue);
  }

  Future<void> setValue(T value) async {
    //更新設定值：將新的值進行正常化後寫入Box中
    await _box.put(key, normalize(value));
  }

  Future<void> reset() => setValue(defaultValue);

  T _read(dynamic rawValue); //

  T normalize(T value); //正常化設定
}

class VolumeSetting extends LocalSettingItem<int> {
  //聲音設定
  VolumeSetting._() : super(_key, 100);

  static const String _key = 'volume';

  int get current => getValue();

  double get ratio => current / 100;

  Future<void> update(int value) => setValue(value);

  @override
  int _read(dynamic rawValue) {
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
  //振動設定
  VibrationSetting._() : super(_key, true);

  static const String _key = 'vibration_enabled';

  bool get isEnabled => getValue();

  Future<void> update(bool enabled) => setValue(enabled);

  Future<void> enable() => setValue(true);

  Future<void> disable() => setValue(false);

  Future<void> toggle() => setValue(!isEnabled);

  @override
  bool _read(dynamic rawValue) {
    if (rawValue is bool) {
      return rawValue;
    }

    return defaultValue;
  }

  @override
  bool normalize(bool value) => value;
}

class AutoSkipStorySetting extends LocalSettingItem<bool> {
  //自動跳過劇情設定
  AutoSkipStorySetting._() : super(_key, false);

  static const String _key = 'auto_skip_story';

  bool get isEnabled => getValue();

  Future<void> update(bool enabled) => setValue(enabled);

  Future<void> enable() => setValue(true);

  Future<void> disable() => setValue(false);

  Future<void> toggle() => setValue(!isEnabled);

  @override
  bool _read(dynamic rawValue) {
    if (rawValue is bool) {
      return rawValue;
    }

    return defaultValue;
  }

  @override
  bool normalize(bool value) => value;
}

class LanguageSetting extends LocalSettingItem<String> {
  //語言設定
  LanguageSetting._() : super(_key, chinese);

  static const String _key = 'language';
  static const String english = 'en';
  static const String chinese = 'zh';

  String get current => getValue();

  bool get isEnglish => current == english;

  bool get isChinese => current == chinese;

  Future<void> update(String language) => setValue(language);

  Future<void> useEnglish() => setValue(english);

  Future<void> useChinese() => setValue(chinese);

  @override
  String _read(dynamic rawValue) {
    if (rawValue is String) {
      return normalize(rawValue);
    }

    return defaultValue;
  }

  @override
  String normalize(String value) {
    if (value == english || value == chinese) {
      return value;
    }

    return defaultValue;
  }
}
