# Campus Tour App Store 正式上架檢查與操作手冊

最後更新：2026-08-16  
Firebase／Google Cloud 專案：`campus-tour-679e9`  
iOS Bundle ID：`com.henryKuo.Campustour`  
目前 App 版本：`1.0.0+4`

這份文件是本專案送交 Apple App Review 前的唯一核對清單。`[x]` 代表從程式庫可確認已完成；`[ ]` 仍需人工確認、後台設定或實機測試。每次正式版送審都應重新走完「必要阻擋項目」和「最終驗收」。

> 重要：Apple、Firebase 與 Google Cloud 後台狀態可能隨時間變動。不要只因程式已完成就勾選後台項目；必須登入對應後台實際確認。

## 一、目前狀態摘要

### 程式內已完成

- [x] App 內有服務條款、隱私權政策與支援入口。
- [x] 正式公開網站已部署：
  - 隱私權政策：https://campus-tour-679e9.web.app/privacy.html
  - 支援頁面：https://campus-tour-679e9.web.app/support.html
  - 服務條款：https://campus-tour-679e9.web.app/terms.html
- [x] App 內可發起完整帳號刪除，並要求再次確認及重新驗證。
- [x] `deleteMyAccount` Callable Function 會遞迴刪除 `users/{uid}`、其子集合、UID Storage 路徑及 Firebase Authentication 使用者。
- [x] Storage bucket 不存在時略過頭像清理；其他 Storage 錯誤會中止刪除，保留帳號以便重試。
- [x] 刪除帳號後會清理本機狀態並返回主畫面，背景音樂會重新啟動。
- [x] Google／Apple／Email 登入均有對應重新驗證流程。
- [x] Release 預設隱藏位置偏移與批次收集精靈測試功能。
- [x] 公開法律網站沒有「準備中」、「暫時替代」等送審 placeholder。

### 上架前阻擋項目（P0）

- [ ] 將 Firestore Rules 建立成專案內的 `firestore.rules`，加入 `firebase.json`，測試後由 CLI 部署；目前規則僅曾出現在 Console／討論內容，無法由 Git 追蹤與重現。
- [ ] 決定是否正式啟用 Firebase Storage。目前預設 bucket 不存在；如果 App 允許上傳頭像，必須建立 bucket、部署 Storage Rules 並完成上傳／刪除測試。
- [ ] 在 iOS 設定 Firebase App Check（建議 App Attest，必要時 DeviceCheck fallback），觀察指標正常後，把 Function 的 `enforceAppCheck` 改為 `true` 並重新部署。
- [ ] 撤回先前為部署暫時授予個人帳號的 `roles/run.admin`（Cloud Run Admin）。日常維護採最小權限。
- [ ] 修正並跑綠完整測試。目前已知完整 `flutter test` 並非全部通過，不能只以翻譯測試通過視為可送審。
- [ ] 在實體 iPhone 上完整測試 Email、Google、Apple 三種帳號的建立、登入、重新驗證與刪除。
- [ ] 準備 Apple 審核帳號、可操作的 NFC／硬體測試方法，以及 Review Notes；審核員必須能進入並體驗主要功能。
- [ ] 確認法律文件中的營運者名稱「中央大學校園導覽團隊」與聯絡信箱 `ideasky716@gmail.com` 是正式且有人持續收信的資料。
- [ ] 完成 App Store Connect 的 App Privacy 問卷，內容必須與 App 實際資料流及隱私權政策一致。

## 二、Apple Developer 與 App Store Connect

### Apple Developer 後台

- [ ] Apple Developer Program 會員有效，且負責送審者具有必要權限。
- [ ] App Identifier 的 Bundle ID 精確為 `com.henryKuo.Campustour`。
- [ ] Capabilities 已啟用：
  - Sign in with Apple
  - NFC Tag Reading
- [ ] Distribution Certificate、Provisioning Profile 與 Xcode Signing Team 正確。
- [ ] Sign in with Apple 已在 Apple Developer、Firebase Authentication 與 Xcode 三處使用同一套 App Identifier／Team 設定。
- [ ] 若 Apple 登入撤銷需要 Private Key，將 Key 放在 Firebase／安全的 Secret 設定中，不得提交到 Git。

### App Store Connect 必填資料

- [ ] 建立 App record，Bundle ID 選 `com.henryKuo.Campustour`。
- [ ] 填寫 App 名稱、副標題、描述、關鍵字、分類、年齡分級、版權與聯絡資料。
- [ ] Privacy Policy URL 填：`https://campus-tour-679e9.web.app/privacy.html`
- [ ] Support URL 填：`https://campus-tour-679e9.web.app/support.html`
- [ ] 服務條款 URL 可放在描述、Review Notes 或自訂 EULA：`https://campus-tour-679e9.web.app/terms.html`
- [ ] 上傳符合目前裝置尺寸要求的真實 App 截圖；不得使用未完成畫面或與版本不符的示意圖。
- [ ] 填寫 App Review Contact、可即時聯絡的電話與 Email。
- [ ] 提供長期有效的審核帳號；不得開啟雙因素驗證、過期密碼或審核期間關閉後端。
- [ ] Review Notes 說明 NFC、定位、相機、照片、抓精靈流程及刪除帳號入口。
- [ ] 回答出口合規（Export Compliance）。本 App 使用 HTTPS／Firebase 等標準加密，但答案仍應依實際二進位與 Apple 當期問項確認。
- [ ] 確認內容授權：校園建築、角色、圖片、音樂、音效、影片、題庫與商標均有權使用及散布。

### App Privacy 建議盤點

以下不是代填答案；送出前要以實際程式、Firebase Console 和第三方服務為準：

| 資料 | 本專案可能用途 | App Store Connect 應確認 |
| --- | --- | --- |
| Email、Firebase UID | 建立帳號、登入、刪除帳號 | 是否與使用者身分連結 |
| 暱稱、頭像／頭像網址 | 個人檔案 | Storage 是否實際啟用與保存 |
| 精靈收集紀錄、遊戲進度 | 提供遊戲功能 | 是否屬 Product Interaction |
| 精確位置 | 尋找鄰近精靈／校園導覽 | 是否只在使用 App 時使用、是否送到伺服器 |
| 相機、照片 | AR／拍照與預覽 | 照片是否只在裝置處理或會上傳 |
| 診斷資料 | Firebase／系統錯誤紀錄 | 是否啟用 Crashlytics、Analytics 或其他 SDK |
| Google／Apple 帳號識別 | 第三方登入 | Provider 分享與撤銷方式 |

- [ ] 確認目前 Firebase Analytics 為停用；若日後啟用，先同步更新隱私政策與 App Privacy。
- [ ] 確認沒有廣告 SDK、跨 App Tracking 或 IDFA；若沒有，不應宣告追蹤，也不需顯示 ATT。
- [ ] 清查 MQTT／其他自架後端是否接收 Firebase ID Token、裝置資料或行為資料，並補進隱私政策。

## 三、iOS 專案檢查

- [ ] `CFBundleDisplayName`、App icon、Launch Screen 與正式品牌一致。
- [ ] 將版本與 Build Number 更新；每次上傳 Build Number 必須遞增。例：`1.0.0+5`。
- [ ] 在 Xcode 的 Signing & Capabilities 檢查 Apple 登入與 NFC entitlement。
- [ ] 檢查 `Info.plist` 權限用途文字：相機、定位、照片、NFC、藍牙均需精確說明功能，不可只寫模糊的「需要權限」。
- [ ] App 支援中／英／日文時，新增並驗證各語言的 `InfoPlist.strings`；目前權限說明主要為中文，英文／日文裝置可能仍顯示中文。
- [ ] 確認 App 不需要的權限已移除，且拒絕定位、相機、照片後不崩潰，並提供合理提示或替代路徑。
- [ ] 限制 iOS Google Maps API Key：只允許 `com.henryKuo.Campustour`，並只開啟實際使用的 Maps API。行動 App Key 會出現在二進位中，安全性依賴後台限制。
- [ ] Google Sign-In OAuth Client、URL Scheme 與 Firebase iOS App 的 Bundle ID 一致。
- [ ] 用目前 Xcode Archive 檢查 Privacy Manifest／Required Reason API 警告；更新不符合 Apple 規範的第三方 SDK。
- [ ] 測試直向與橫向。如果畫面只設計直向，移除未支援的橫向宣告。
- [ ] Release 建置不得傳入：
  - `SHOW_LOCATION_OFFSET_CONTROLS=true`
  - `SHOW_MONSTER_COLLECTION_CONTROLS=true`
- [ ] 搜尋並移除測試帳密、測試入口、假資料、空 URL、未完成按鈕與 debug log 中的敏感資料。

## 四、Firebase Authentication

- [ ] Firebase Console > Authentication > Sign-in method 已啟用 Email/Password、Google、Apple。
- [ ] Google Support Email、OAuth Consent Screen、App 名稱與 Logo 已正式設定。
- [ ] Apple Provider 的 Service ID／Team ID／Key ID／Private Key 仍有效（依目前整合方式填寫）。
- [ ] Authentication 的 Authorized Domains 只保留需要的網域。
- [ ] 測試 Apple 的「隱藏我的 Email」帳號。
- [ ] 測試同一 Email 使用不同 Provider 時的帳號連結／錯誤提示，避免誤顯示「Apple 登入已連結」。
- [ ] 設定密碼政策，並驗證忘記密碼 Email 的寄件者、語言、Action URL 與 Dynamic Link／Universal Link 行為。
- [ ] 檢查 Firebase Authentication Email template 的 App 名稱、語言、支援信箱及網址。

## 五、Firestore Rules 與資料

目前最大的部署缺口是規則未隨程式版本控制。正式做法：

1. 在專案根目錄建立 `firestore.rules`，放入已審核的正式規則。
2. 在 `firebase.json` 加入：

```json
{
  "firestore": {
    "rules": "firestore.rules"
  }
}
```

3. 以 Emulator／Rules Unit Testing 測試至少以下情境：
   - 未登入者不能讀寫。
   - 一般使用者只能讀寫自己的 `users/{uid}` 與 `users/{uid}/monsters/*`。
   - 一般使用者不能直接刪除父文件或修改公開遊戲資料。
   - 管理員才可修改 monsters、architectures、questions。
   - 硬體帳號只能操作指定 HardwareDevice 路徑。
   - 額外欄位、錯誤型別與冒用 UID 均被拒絕。
4. 部署並確認版本：

```bash
firebase deploy --only firestore:rules --project campus-tour-679e9
```

- [ ] 不要長期把管理員／硬體權限只綁死在程式碼中的 UID。正式環境建議改用 Firebase Custom Claims，並建立受控的授權／撤權程序。
- [ ] 確認正式資料中的必要欄位符合規則，避免規則上線後舊資料無法更新。
- [ ] 匯出或備份正式 Firestore 資料，並建立復原演練與保存政策。

## 六、Cloud Functions：刪除帳號

### 現有設計

`functions/src/index.ts` 的 `deleteMyAccount` 部署於 `asia-east1`，使用 Node.js 22。流程為：

1. 驗證 Firebase Authentication。
2. 驗證登入時間不超過 5 分鐘。
3. 遞迴刪除 `users/{uid}` 及所有子集合。
4. 刪除 Storage 的 `users/{uid}/` 前綴。
5. Storage bucket 不存在（404）時記錄 warning 後繼續；其他錯誤中止。
6. 最後刪除 Firebase Authentication 使用者，確保前面失敗時仍可重試。

Google／Apple Provider 的撤銷及本機 Hive／快取清理，由 App 端配合處理。

### 建置與部署

```bash
cd functions
npm ci
npm run build
cd ..
firebase deploy \
  --only functions:deleteMyAccount \
  --project campus-tour-679e9 \
  --force
```

> `functions/package.json` 使用 ESLint 9，但目前需確認已有相容的 `eslint.config.js`；`npm run lint` 必須在送審前修到通過，不能因 build 成功而略過 lint。

### Cloud Run IAM 的正確狀態

- [ ] Gen 2 Callable Function 底層 Cloud Run 服務保留 `allUsers -> roles/run.invoker`，讓 Firebase SDK 能呼叫端點。
- [x] Function 程式本身要求 `request.auth` 且檢查最近登入；知道 URL 不等於能刪除任意帳號。
- [ ] 撤回 `caijamie2004@gmail.com`（或當時部署帳號）的暫時 `roles/run.admin`，除非其工作職責確實需要長期管理 Cloud Run。
- [ ] Runtime Service Account 目前應另行在 Cloud Console 核對。若仍使用 `322346919988-compute@developer.gserviceaccount.com`，審查其角色並考慮改成專用、最小權限 Service Account。

查看 Function 狀態與記錄：

```bash
firebase functions:list --project campus-tour-679e9
firebase functions:log \
  --only deleteMyAccount \
  --project campus-tour-679e9
```

### Firebase App Check

目前 `deleteMyAccount` 設為 `enforceAppCheck: false`。正式啟用順序：

1. Firebase Console > App Check 註冊 iOS App。
2. 正式版優先使用 App Attest；為不支援情境設定合適 fallback。
3. 開發／CI 只使用明確登記的 Debug Token，不可把 token 寫入 Git。
4. 先監看 App Check Metrics，確認正式客戶端能送出有效 token。
5. 將 `enforceAppCheck` 改為 `true`，build、deploy。
6. 用實體 iPhone 重測帳號刪除；無效 App Check 請求應被拒絕。

切勿先強制再發布支援 App Check 的 App，否則現有使用者會無法刪除帳號。

## 七、Firebase Storage

目前 `campus-tour-679e9.firebasestorage.app` bucket 不存在。需二選一：

### A. App 正式需要頭像／檔案上傳

- [ ] 在 Firebase Console 建立 Storage bucket，區域需考慮延遲、費用與資料所在地。
- [ ] 所有使用者私有檔案統一放在 `users/{uid}/...`，才能由刪除 Function 完整清理。
- [ ] 建立 `storage.rules` 並在 `firebase.json` 納入版本控制。
- [ ] Rules 至少驗證 `request.auth.uid == uid`、檔案大小及允許的 MIME type。
- [ ] 部署：`firebase deploy --only storage --project campus-tour-679e9`
- [ ] 實測上傳、讀取、替換、登出權限與刪除帳號後無殘留檔案。

### B. App 正式不需要上傳

- [ ] UI 不可讓使用者誤以為頭像會上傳雲端。
- [ ] 隱私政策不得宣稱實際不存在的雲端照片處理。
- [ ] 保留 Function 對 bucket 404 的容錯沒有問題，但應在監控中辨別這是預期 warning。

## 八、Firebase Hosting 與法律頁面

Markdown 正式內容位於：

- `docs/terms_of_service_zh-TW.md`
- `docs/privacy_policy_zh-TW.md`

重新產生網站並部署：

```bash
node tool/build_legal_site.js
firebase deploy --only hosting --project campus-tour-679e9
```

部署後逐一以未登入／無痕視窗開啟首頁、條款、隱私與支援頁：

- [ ] HTTPS 正常，手機版可閱讀。
- [ ] 沒有 404、空白頁、測試文字或失效連結。
- [ ] 版本日期、聯絡 Email、資料保存與刪除流程正確。
- [ ] 條款、隱私政策、App 實際功能及 App Privacy 問卷內容一致。
- [ ] 所有正式市場需要的語言版本均可公開閱讀；至少確保 App Store 主要市場使用者能理解。
- [ ] 法律內容由專案負責人／必要時法律專業人士做最終審閱。

## 九、Google Cloud、費用與安全

- [ ] Firebase 專案維持可用的 Blaze 計費方案，否則 Gen 2 Functions／相關 Google Cloud 資源可能無法運作。
- [ ] 設定 Billing Budget 與 Email 警示；注意 Budget 不會自動停止服務。
- [ ] Artifact Registry 已設定清理政策後，仍定期確認映像檔費用與保留需求。
- [ ] Cloud Logging 設定合理保存期與告警：Function 5xx、帳號刪除失敗、異常大量呼叫。
- [ ] IAM 移除不再需要的人員、Owner、Editor、Cloud Run Admin；管理員使用 MFA。
- [ ] 不把 Service Account JSON、Apple Private Key、OAuth Secret、API Secret 或 Debug Token 提交到 Git。
- [ ] Google Maps API Key 設定 iOS Application Restriction、API Restriction 及用量警示。
- [ ] 若啟用 MQTT：只允許 TLS 連線、驗證 Broker 憑證、限制 topic ACL，且不得透過明文 MQTT 傳送 Firebase ID Token。現在 `Esp32MQTT_info` 的 broker 與 port 為空白／`0000`，正式功能啟用前必須完成安全設定；若未使用則移除或確保無法觸發。

## 十、帳號刪除驗收矩陣

每個 Provider 都要用全新的測試帳號執行一次，並直接在 Firebase Console／Storage 查驗結果。

| 情境 | Email | Google | Apple |
| --- | --- | --- | --- |
| 顯示不可復原警告並再次確認 | [ ] | [ ] | [ ] |
| 取消後不刪除任何資料 | [ ] | [ ] | [ ] |
| 密碼／Provider 重新驗證成功 | [ ] | [ ] | [ ] |
| 重新驗證取消或失敗時保留帳號 | [ ] | [ ] | [ ] |
| `users/{uid}/monsters` 全部刪除 | [ ] | [ ] | [ ] |
| `users/{uid}` 與其他 UID 關聯資料刪除 | [ ] | [ ] | [ ] |
| Storage `users/{uid}/` 無殘留 | [ ] | [ ] | [ ] |
| Google／Apple 存取權撤銷 | N/A | [ ] | [ ] |
| Firebase Authentication 使用者刪除 | [ ] | [ ] | [ ] |
| Hive、登入狀態與快取清除 | [ ] | [ ] | [ ] |
| 返回主畫面且背景音樂正常 | [ ] | [ ] | [ ] |
| 相同帳號可重新註冊且無舊資料 | [ ] | [ ] | [ ] |

另外測試：離線、Function timeout、Storage 權限錯誤、重複按下刪除、流程中途關閉 App，以及失敗後重試。不得向使用者顯示只有「無法刪除帳號」而沒有可理解的下一步；同時不要把內部錯誤或敏感資訊直接顯示在 UI。

## 十一、品質、翻譯與實機測試

### 自動檢查

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
cd functions
npm ci
npm run lint
npm run build
```

- [ ] 所有命令 exit code 為 0。
- [ ] 翻譯完整性測試確認中／英／日：無缺 key、無空字串、無錯誤回退。
- [ ] 搜尋畫面中的硬編碼使用者文字；除品牌名、資料內容或技術識別字外皆改用翻譯 key。
- [ ] NFC 動畫、錯誤訊息、登入、刪除帳號、權限、法律文件入口均在三語實機確認。

### 實機／TestFlight

- [ ] 至少測最新 iOS 與專案支援的最低 iOS 版本。
- [ ] 至少一台實體 iPhone；若宣告支援 iPad，必須在 iPad 測試完整版面。
- [ ] 全新安裝、覆蓋更新、登出重登、App 被系統終止後恢復。
- [ ] 網路正常、慢速、斷線、Firebase 暫時失敗。
- [ ] 定位／相機／照片／NFC／藍牙：允許、拒絕、之後到設定開啟。
- [ ] Google／Apple／Email 登入、忘記密碼與取消登入流程。
- [ ] 地圖、AR、NFC、抓精靈、圖鑑、音樂、音效與多語切換。
- [ ] VoiceOver、Dynamic Type、對比度、按鈕觸控範圍與鍵盤遮擋。
- [ ] TestFlight 外部測試者無需工程師協助也能完成主要流程。

## 十二、正式建置與上傳

先更新 `pubspec.yaml` 的版本，例如：

```yaml
version: 1.0.0+5
```

確認所有測試通過後：

```bash
flutter clean
flutter pub get
flutter build ipa --release \
  --build-name=1.0.0 \
  --build-number=5
```

- [ ] 建置命令沒有加入任何測試用 `--dart-define`。
- [ ] 使用 Xcode Organizer 驗證 Archive、簽章、entitlements 與 Privacy Manifest。
- [ ] 上傳後查看 App Store Connect 的 Processing、Export Compliance 與 Missing Compliance 警告。
- [ ] 從 TestFlight 安裝 Apple 處理後的實際 Build，再跑一次冒煙測試。
- [ ] 將送審的 Git commit／tag、Build Number、Function revision、Rules release 與 Hosting deploy 時間記錄在 release notes。

## 十三、可貼入 App Review Notes 的範本

送出前務必把 `<...>` 全部換成真實內容；這些符號不可原樣送審。

```text
Campus Tour is a campus exploration game that uses location, camera, and NFC
to let users discover and collect characters near campus landmarks.

Review account:
Email: <REVIEW_ACCOUNT_EMAIL>
Password: <REVIEW_ACCOUNT_PASSWORD>

Account deletion:
Sign in, open Settings, select Account Security, then select Delete Account.
The app asks for confirmation and recent authentication before permanently
deleting the Firebase account and associated user data.

NFC / hardware review:
<EXPLAIN HOW THE REVIEWER CAN ACCESS THE FEATURE WITHOUT PRIVATE ASSISTANCE,
OR PROVIDE A COMPLETE DEMO PATH AND TEST TAG/DEVICE INSTRUCTIONS.>

Location and camera permissions are requested only when their related gameplay
features are used. Privacy Policy:
https://campus-tour-679e9.web.app/privacy.html

Support contact: ideasky716@gmail.com
```

## 十四、上線後

- [ ] 監看 Crash、Function 5xx、Authentication、App Check、Firestore 拒絕與帳號刪除失敗。
- [ ] 支援信箱在承諾時間內回覆，並保存必要的處理紀錄。
- [ ] 有可執行的 App 回退／Hotfix 流程，但不可為回退破壞已上線資料格式。
- [ ] 每次新增 SDK、資料欄位、用途、Provider、權限或第三方分享前，先更新隱私評估、政策與 App Privacy。
- [ ] 定期測試公開 URL、刪除帳號與後端，不能只在首次送審前測一次。

## 最終 Definition of Done

只有以下全部成立才可按「Submit for Review」：

- [ ] P0 阻擋項目全數完成。
- [ ] Flutter、Functions lint/build、全部測試均通過。
- [ ] Firestore／Storage／Function／Hosting 已部署正確版本，且後端在審核期間持續開啟。
- [ ] 三種登入與帳號刪除完成實機端到端驗證。
- [ ] App Store metadata、App Privacy、權限用途與隱私政策一致。
- [ ] 審核帳號、NFC 測試方式與 Review Notes 可由不熟悉專案的人獨立操作。
- [ ] TestFlight 的最終 Build 無測試入口、placeholder、失效網址、明顯錯字或崩潰。

## 官方參考文件

- Apple App Review Guidelines：https://developer.apple.com/app-store/review/guidelines/
- Apple 帳號刪除要求：https://developer.apple.com/support/offering-account-deletion-in-your-app/
- Apple App Review 準備：https://developer.apple.com/app-store/review/
- App Store Connect App Privacy：https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/
- Firebase Functions 入門與部署：https://firebase.google.com/docs/functions/get-started
- Firebase Functions 管理：https://firebase.google.com/docs/functions/manage-functions
- Firebase App Check for Cloud Functions：https://firebase.google.com/docs/app-check/cloud-functions
- Firebase Storage Security Rules：https://firebase.google.com/docs/storage/security/rules-conditions
- Firebase CLI：https://firebase.google.com/docs/cli

