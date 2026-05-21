# Campus Tour

Campus Tour 是一款以中央大學校園為場景的 Flutter 導覽遊戲。玩家會在客製化校園地圖上移動，透過定位尋找附近的校園精靈，完成劇情、圖文觀察、NFC 掃描與問答任務後將精靈加入圖鑑。

## 專案特色

- 校園地圖探索：使用 Google Maps Flutter 搭配本地 tile overlay 呈現客製化 NCU 校園地圖。
- 定位與附近精靈：透過 Geolocator 監聽玩家位置，顯示附近可捕捉精靈與最近精靈方向提示。
- 任務式捕捉流程：依建築類型組合劇情關卡、圖文線索、NFC 掃描與密碼/問答關卡。
- 使用者與圖鑑：Firebase Auth、Firestore 與 GetX 管理登入狀態、使用者資料與已捕捉精靈。
- 多媒體互動：支援 BGM/SFX、相機、AR 相關頁面、震動回饋與相簿儲存。

## 技術棧

- Flutter / Dart
- GetX 狀態管理與路由輔助
- Firebase Core、Auth、Cloud Firestore、Storage
- Google Maps Flutter
- Geolocator、Flutter Compass
- NFC Manager
- Camera、Image Picker、Video Player
- Hive 本地設定儲存
- Audioplayers

## 專案結構

```text
campus_tour/
├── lib/
│   ├── controllers/        # GetX controllers、定位/NFC/登入等流程控制
│   ├── local_information/  # 本地設定，例如自動略過劇情
│   ├── models/             # Firestore 與遊戲資料模型
│   ├── services/           # Firebase、音效、資料匯入、相機等服務
│   ├── styles/             # 頁面與元件樣式
│   ├── view/               # 主要頁面
│   └── widgets/            # 可重用 UI 與遊戲元件
├── assets/
│   ├── audio/              # BGM 與音效
│   ├── images/             # 角色、背景、圖鑑與 UI 圖像
│   ├── json/               # 建築、精靈、題目等初始化資料
│   ├── mapStyles/          # Google Map style JSON
│   └── tiles/              # 本地校園地圖 tiles
├── test/                   # Widget/unit tests 與測試文件
├── android/
├── ios/
└── pubspec.yaml
```

## 環境需求

- Flutter SDK，需支援 Dart `^3.11.3`
- Android Studio 或 Xcode
- Firebase 專案設定
- Google Maps API Key
- 測試定位、NFC、相機或 AR 功能時，建議使用實體裝置

## 安裝與執行

1. 進入 Flutter app 目錄：

```bash
cd campus_tour
```

2. 安裝套件：

```bash
flutter pub get
```

3. 設定 Firebase：

專案目前已包含 `lib/firebase_options.dart`，並由 `Firebase.initializeApp` 初始化。若要換成自己的 Firebase 專案，請使用 FlutterFire CLI 重新產生設定：

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4. 設定 Android Google Maps API Key：

在 `android/local.properties` 加入：

```properties
MAPS_API_KEY=你的 Google Maps API Key
```

Android 端會透過 `android/app/build.gradle.kts` 將 `MAPS_API_KEY` 注入 `AndroidManifest.xml`。

5. 執行專案：

```bash
flutter run
```

常用指定平台：

```bash
flutter run -d android
flutter run -d ios
```

## Firebase 資料

啟動時 `main.dart` 會呼叫：

```dart
await LoadDbService().loadArchitecture();
```

這會將 `assets/json/architecture.json` 匯入 Firestore 的 `architectures` collection。`LoadDbService` 也提供精靈與題目匯入方法：

- `loadMonsters()` → `assets/json/monster.json` → `monsters`
- `loadArchitecture()` → `assets/json/architecture.json` → `architectures`
- `loadQA()` → `assets/json/qa.json` → `questions`

如需初始化完整資料，可依需求在 `lib/main.dart` 暫時開啟對應呼叫，匯入完成後再關閉，避免每次啟動重複寫入。

## 權限需求

此專案會用到下列裝置權限：

- 定位：校園地圖、玩家位置、附近精靈偵測
- 相機：AR/拍照相關功能
- NFC：任務線索掃描
- 相簿：儲存照片
- 震動：遊戲互動回饋

Android 權限主要設定於 `android/app/src/main/AndroidManifest.xml`。iOS 權限描述位於 `ios/Runner/Info.plist`。

## 測試與檢查

```bash
flutter analyze
flutter test
```

目前部分測試會依賴 Firebase、Firestore 或平台功能；若在純本機環境執行失敗，請先確認 Firebase 初始化、測試資料與裝置/模擬器權限設定。

## 主要流程

1. `main.dart` 初始化 Hive、本地設定、Firebase 與 GetX controllers。
2. `StartPage` 播放首頁背景輪播與 BGM。
3. 登入/註冊後進入 `GameMainPage`。
4. `GameMap` 載入地圖樣式、本地 tiles，並監聽玩家定位。
5. `MonsterController` 依位置更新附近精靈、最近精靈與使用者圖鑑狀態。
6. 玩家接近精靈後進入 `FullMissionPage` 任務流程。
7. 任務完成後寫入 Firestore，將精靈加入使用者圖鑑。

## 常見問題

### 地圖沒有顯示

- 確認 Google Maps API Key 已設定。
- Android 檢查 `android/local.properties` 是否包含 `MAPS_API_KEY`。
- iOS 檢查 `ios/Runner/Info.plist` 的 `GMSApiKey`。
- 確認裝置有網路，且 Google Maps SDK/API 已在 Google Cloud Console 啟用。

### 附近精靈沒有更新

- 確認定位服務已開啟並授權。
- 確認 Firestore 中 `monsters` 資料存在且座標正確。
- 若使用模擬器，請手動設定模擬定位到中央大學附近。

### NFC 掃描無反應

- 確認使用支援 NFC 的實體裝置。
- Android 需開啟系統 NFC。
- iOS 需確認 App entitlement 與 `NFCReaderUsageDescription` 設定。

## 開發備註

- 地圖 tiles 已放在 `assets/tiles/`，新增 zoom/x/y tile 時也要同步更新 `pubspec.yaml` assets。
- 捕捉任務會依建築類型切換任務組合，核心邏輯在 `BuildingMonsterLevel` 與 `FullMissionPage`。
