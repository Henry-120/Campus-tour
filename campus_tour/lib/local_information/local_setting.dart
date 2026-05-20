import 'package:hive_flutter/hive_flutter.dart';

class LocalSettingService {
  // [L-01]
  LocalSettingService._();

  // [L-02]
  static const String _boxName = 'local_settings';
  // [L-03]
  static late final Box<dynamic> _box;
  // [L-04]
  static bool _isInitialized = false; //初始化完成否
  // [L-05]
  static Future<void>? _initFuture; //是否正在執行初始化

  // [L-06]
  static final VolumeSetting volume = VolumeSetting._();
  static final VibrationSetting vibration = VibrationSetting._();
  static final AutoSkipStorySetting autoSkipStory = AutoSkipStorySetting._();
  static final LanguageSetting language = LanguageSetting._();
  static final NoviceTeachingSetting noviceTeaching = NoviceTeachingSetting._();

  static Future<void> initBox() {
    // [L-07]
    if (_isInitialized) {
      return Future.value();
    }

    // [L-08]
    return _initFuture ??= _initialize();
  }

  static Future<void> _initialize() async {
    // [L-09]
    await Hive.initFlutter();
    // [L-10]
    _box = await Hive.openBox<dynamic>(_boxName);

    // [L-11]
    await volume.ensureInitialized(_box);
    await vibration.ensureInitialized(_box);
    await autoSkipStory.ensureInitialized(_box);
    await language.ensureInitialized(_box);
    await noviceTeaching.ensureInitialized(_box);

    _isInitialized = true;
  } //初始化過程並隱式回傳Future<void>

  static Box<dynamic> get settingsBox {
    // [L-12]
    if (!_isInitialized) {
      throw StateError(
        'LocalSettingService.initBox() must be called before using settings.',
      );
    }

    // [L-13]
    return _box;
  }
}

abstract class LocalSettingItem<T> {
  // [L-14]
  const LocalSettingItem(this.key, this.defaultValue);

  final String key;
  final T defaultValue;

  // [L-15]
  Box<dynamic> get _box => LocalSettingService.settingsBox; //取得Box本身

  Future<void> ensureInitialized(Box<dynamic> box) async {
    //初始化設定項目：如果Box中沒有對應的key，則放入預設值
    // [L-16]
    if (!box.containsKey(key)) {
      // [L-17]
      await box.put(key, normalize(defaultValue));
    }
  }

  T getValue() {
    //取得設定值：從Box中讀取對應key的值，進行正常化檢查
    // [L-18]
    final dynamic rawValue = _box.get(key);
    // [L-19]
    if (rawValue == null) {
      return normalize(defaultValue);
    }

    // [L-20]
    return _read(rawValue);
  }

  Future<void> setValue(T value) async {
    //更新設定值：將新的值進行正常化後寫入Box中
    // [L-21]
    await _box.put(key, normalize(value));
  }

  // [L-22]
  Future<void> reset() => setValue(defaultValue);

  T _read(dynamic rawValue); //

  T normalize(T value); //正常化設定
}

class VolumeSetting extends LocalSettingItem<int> {
  //聲音設定
  // [L-23]
  VolumeSetting._() : super(_key, 100);

  static const String _key = 'volume';

  // [L-24]
  int get current => getValue();

  // [L-25]
  double get ratio => current / 100;

  // [L-26]
  Future<void> update(int value) => setValue(value);

  @override
  int _read(dynamic rawValue) {
    // [L-27]
    if (rawValue is int) {
      return normalize(rawValue);
    }

    // [L-28]
    if (rawValue is num) {
      return normalize(rawValue.round());
    }

    // [L-29]
    return defaultValue;
  }

  @override
  // [L-30]
  int normalize(int value) => value.clamp(0, 100).toInt();
}

class VibrationSetting extends LocalSettingItem<bool> {
  //振動設定
  // [L-31]
  VibrationSetting._() : super(_key, true);

  static const String _key = 'vibration_enabled';

  // [L-32]
  bool get isEnabled => getValue();

  // [L-33]
  Future<void> update(bool enabled) => setValue(enabled);

  // [L-34]
  Future<void> enable() => setValue(true);

  // [L-35]
  Future<void> disable() => setValue(false);

  // [L-36]
  Future<void> toggle() => setValue(!isEnabled);

  @override
  bool _read(dynamic rawValue) {
    // [L-37]
    if (rawValue is bool) {
      return rawValue;
    }

    // [L-38]
    return defaultValue;
  }

  @override
  // [L-39]
  bool normalize(bool value) => value;
}

class AutoSkipStorySetting extends LocalSettingItem<bool> {
  //自動跳過劇情設定
  // [L-40]
  AutoSkipStorySetting._() : super(_key, false);

  static const String _key = 'auto_skip_story';

  // [L-41]
  bool get isEnabled => getValue();

  // [L-42]
  Future<void> update(bool enabled) => setValue(enabled);

  // [L-43]
  Future<void> enable() => setValue(true);

  // [L-44]
  Future<void> disable() => setValue(false);

  // [L-45]
  Future<void> toggle() => setValue(!isEnabled);

  @override
  bool _read(dynamic rawValue) {
    // [L-46]
    if (rawValue is bool) {
      return rawValue;
    }

    // [L-47]
    return defaultValue;
  }

  @override
  // [L-48]
  bool normalize(bool value) => value;
}

class NoviceTeachingSetting extends LocalSettingItem<bool> {
  //是否經歷過新手教學
  // [L-49]
  NoviceTeachingSetting._() : super(_key, false);

  static const String _key = 'has_experienced_novice_teaching';

  // [L-50]
  bool get hasExperienced => getValue();

  // [L-51]
  Future<void> update(bool experienced) => setValue(experienced);

  // [L-52]
  Future<void> markExperienced() => setValue(true);

  // [L-53]
  Future<void> resetExperience() => setValue(false);

  @override
  bool _read(dynamic rawValue) {
    // [L-54]
    if (rawValue is bool) {
      return rawValue;
    }

    // [L-55]
    return defaultValue;
  }

  @override
  // [L-56]
  bool normalize(bool value) => value;
}

class LanguageSetting extends LocalSettingItem<String> {
  //語言設定
  // [L-57]
  LanguageSetting._() : super(_key, chinese);

  static const String _key = 'language';
  // [L-58]
  static const String english = 'en';
  static const String chinese = 'zh';

  // [L-59]
  String get current => getValue();

  // [L-60]
  bool get isEnglish => current == english;

  // [L-61]
  bool get isChinese => current == chinese;

  // [L-62]
  Future<void> update(String language) => setValue(language);

  // [L-63]
  Future<void> useEnglish() => setValue(english);

  // [L-64]
  Future<void> useChinese() => setValue(chinese);

  @override
  String _read(dynamic rawValue) {
    // [L-65]
    if (rawValue is String) {
      return normalize(rawValue);
    }

    // [L-66]
    return defaultValue;
  }

  @override
  String normalize(String value) {
    // [L-67]
    if (value == english || value == chinese) {
      return value;
    }

    // [L-68]
    return defaultValue;
  }
}
