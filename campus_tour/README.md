# Campus Tour

Campus Tour 是一款以中央大學校園為場景的 Flutter 導覽遊戲。玩家會在客製化校園地圖上移動，透過定位尋找附近的校園精靈，完成劇情、圖文觀察、NFC 掃描與問答任務後將精靈加入圖鑑。

## 專案特色

- 校園地圖探索：使用 Google Maps Flutter 搭配本地 tile overlay 呈現客製化 NCU 校園地圖。
- 定位與附近精靈：透過 Geolocator 監聽玩家位置，顯示附近可捕捉精靈與最近精靈方向提示。
- 任務式捕捉流程：依建築類型組合劇情關卡、圖文線索、NFC 掃描與密碼/問答關卡。
- 使用者與圖鑑：Firebase Auth、Firestore 與 GetX 管理登入狀態、使用者資料與已捕捉精靈。
- 多媒體互動：支援 BGM/SFX、相機、iOS AR 放置/操控、震動回饋與相簿儲存。
- 平台差異 UI：iOS 顯示 AR StoneButton；Android 隱藏 AR 功能並放大底部 StoneButton。
- 開發測試工具：Debug 模式下可在設定中心一鍵將所有精靈加入目前使用者圖鑑。

## 技術棧

- Flutter / Dart
- GetX 狀態管理與路由輔助
- Firebase Core、Auth、Cloud Firestore、Storage
- Google Maps Flutter
- Geolocator、Flutter Compass
- NFC Manager
- Camera、Image Picker、Video Player
- ARKit Plugin、Vector Math
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
│   └── widgets/            # 可重用 UI、AR 控制器與遊戲元件
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
- ARKit 功能僅在 iOS 裝置顯示入口；Android 目前不顯示 AR StoneButton

目前本機可用的 Flutter SDK 路徑：

```bash
/Users/jamie/Development/flutter/bin/flutter
```

若終端機執行 `flutter` 顯示 command not found，請把正確路徑加入 shell 設定，例如 `~/.zshrc`：

```bash
export PATH="$PATH:/Users/jamie/Development/flutter/bin"
```

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

`LoadDbService` 提供初始化資料匯入方法：

- `loadMonsters()` → `assets/json/monster.json` → `monsters`
- `loadArchitecture()` → `assets/json/architecture.json` → `architectures`
- `loadQA()` → `assets/json/qa.json` → `questions`

如需初始化完整資料，可依需求在 `lib/main.dart` 暫時開啟對應呼叫，匯入完成後再關閉，避免每次啟動重複寫入。正式上架版本不建議在 app 啟動時自動匯入資料。

## 權限需求

此專案會用到下列裝置權限：

- 定位：校園地圖、玩家位置、附近精靈偵測
- 相機：拍照與 iOS AR 相關功能
- NFC：任務線索掃描
- 相簿：儲存照片
- 震動：遊戲互動回饋

Android 權限主要設定於 `android/app/src/main/AndroidManifest.xml`。iOS 權限描述位於 `ios/Runner/Info.plist`。

## 平台功能差異

- iOS：底部系統選單顯示「圖鑑、相機、AR、設定」，StoneButton 基礎尺寸為 `90`。
- Android：底部系統選單顯示「圖鑑、相機、設定」，不顯示 AR 入口，StoneButton 基礎尺寸為 `110`。
- AR 頁面不會自動預選精靈；玩家需先手動選擇下方列表中的精靈，再點擊 AR 平面放置。
- 選到特定支援操控的模型時會進入 AR 操控頁，可使用虛擬搖桿移動精靈並用跳舞按鈕切換動畫。

## 開發測試功能

Debug build 的設定中心會顯示「測試：捕捉全部精靈」卡片。點擊「一鍵捕捉全部」會把 Firestore `monsters` 集合中尚未捕捉的精靈加入目前登入使用者的 `users/{uid}/monsters` 圖鑑子集合。

此功能使用 monster id 作為 user monster document id，因此重複點擊不會洗出重複收藏。Release build 預設不顯示此測試卡片；內部測試版可在建置時加上 `--dart-define=SHOW_MONSTER_COLLECTION_CONTROLS=true` 來保留「新增全部」與「刪除全部」。「匯入遊戲資料」仍只會出現在 Debug build。

## 測試與檢查

```bash
flutter analyze
flutter test
flutter build apk --release
flutter build ios --release
```

目前部分測試會依賴 Firebase、Firestore 或平台功能；若在純本機環境執行失敗，請先確認 Firebase 初始化、測試資料與裝置/模擬器權限設定。

## 上架檢查清單

### App 身分與版本

- Android `applicationId` 不可維持 `com.example.campus_tour`，上架前需改成正式且唯一的 ID，例如 `tw.edu.ncu.campus_tour`。
- iOS `Bundle Identifier` 需與 Apple Developer 後台、Firebase iOS app 設定一致。
- 更新 `pubspec.yaml` 的 `version: x.y.z+buildNumber`；每次送審 build number 都必須遞增。
- App 名稱、icon、啟動畫面與商店截圖需確認為正式版素材。

### 簽章與建置

- Android release 不能使用 debug signing；需建立正式 keystore，並在 `android/app/build.gradle.kts` 設定 release signingConfig。
- iOS 需確認 Team、Signing Certificate、Provisioning Profile、Capabilities 都使用正式設定。
- 送審前至少跑過 `flutter analyze`、`flutter test`、Android release build、iOS release/archive。

### Firebase

- Firebase Auth 需確認 Email/Password、Google Sign-In 等 provider 已開啟。
- Google Sign-In：Android 需設定正式 keystore 的 SHA-1 / SHA-256；iOS 需確認 `GoogleService-Info.plist` 與 URL Scheme。
- `google-services.json`、`GoogleService-Info.plist`、`lib/firebase_options.dart` 必須屬於正式 Firebase 專案或正式環境。
- Firestore Rules 不可使用測試模式。建議限制使用者只能讀寫自己的 `users/{uid}`，公開資料如 `monsters`、`architectures`、`questions` 只開放必要讀取。
- Storage Rules 需限制可讀寫路徑、檔案大小與 content type。
- 建議啟用 Firebase App Check，降低 Firestore / Storage 被非正式 app 濫用的風險。
- `LoadDbService` 只應用於資料初始化或管理流程，不要在正式 app 啟動時自動寫入 Firestore。

### Google Maps 與 API Key

- Android Maps API Key 建議放在 `android/local.properties`，不要提交真正密鑰到公開 repo。
- Google Cloud Console 中限制 API key：Android 使用 package name + SHA，iOS 使用 bundle id。
- 確認 Maps SDK for Android / iOS 已啟用，並設定帳單與配額警示。

### 權限與隱私

- Android / iOS 權限文字需清楚說明用途：定位、相機、NFC、相簿、震動、AR。
- App Store Connect 與 Google Play Console 的資料安全/隱私權表單需與實際行為一致。
- 若收集定位、帳號、照片或遊戲紀錄，需準備隱私權政策網址。
- 定位功能應只要求實際需要的權限；目前主要使用前景定位，若沒有背景追蹤需求，不要宣稱或要求背景定位。

### 平台功能

- NFC、ARKit、相機、定位、羅盤、震動最好用實體 Android/iPhone 測試；模擬器無法完整驗證。
- iOS 使用 ARKit 時需確認目標裝置支援；不支援時應有可接受的錯誤提示或替代流程。
- Android 若未來加入 ARCore，也需確認裝置支援與 Play Console device compatibility。

### 資料與營運

- Firestore 中的 `monsters`、`architectures`、`questions`、使用者初始資料需在正式環境完整建立。
- 檢查所有 assets 是否列在 `pubspec.yaml`，尤其地圖 tiles、精靈圖片、影片、音效與 AR 模型。
- 檢查音效、圖片、影片、地圖資料、角色素材是否有可上架使用的授權。
- 建議建立 staging / production Firebase 專案，避免測試資料混入正式環境。

## 主要流程

1. `main.dart` 初始化 Hive、本地設定、Firebase 與 GetX controllers。
2. `StartPage` 播放首頁背景輪播與 BGM。
3. 登入/註冊後進入 `GameMainPage`。
4. `GameMap` 載入地圖樣式、本地 tiles，並監聽玩家定位。
5. `MonsterController` 依位置更新附近精靈、最近精靈與使用者圖鑑狀態。
6. 玩家接近精靈後進入 `FullMissionPage` 任務流程。
7. 任務完成後寫入 Firestore，將精靈加入使用者圖鑑。
8. 登出時會清除 Firebase/Google 登入狀態、使用者資料、怪物/圖鑑狀態，並清空 navigation stack 回到 `StartPage`。

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

### AR 按鈕沒有出現

- 目前 AR 入口只在 iOS 顯示；Android 會隱藏 AR StoneButton。
- iOS 請確認使用支援 ARKit 的實體裝置。
- 確認 `ios/Runner/Info.plist` 有相機權限描述，且 AR 模型資源已加入 iOS project resources。

## 開發備註

- 地圖 tiles 已放在 `assets/tiles/`，新增 zoom/x/y tile 時也要同步更新 `pubspec.yaml` assets。
- 捕捉任務會依建築類型切換任務組合，核心邏輯在 `BuildingMonsterLevel` 與 `FullMissionPage`。
- `MonsterController.captureAllMonstersForTesting` 僅供 Debug 測試使用；正式流程仍應透過任務捕捉精靈。
