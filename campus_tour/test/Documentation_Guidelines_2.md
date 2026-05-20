
## Task 0: 檔案用途與使用方式

在撰寫邏輯對照表的過程中，請一併判斷此檔案的用途，並補充「使用方式或呼叫方式」。

此段落的重點不是完整介紹架構，而是讓第一次看到這個檔案的人，可以快速知道：

- 這個檔案的東西要怎麼用？
- 如果要呼叫它，應該在哪裡呼叫？
- 要傳入什麼參數？
- 回傳什麼結果？
- 使用時要注意什麼？

---

## 0-1. 檔案簡介

請用 3 到 5 句話說明：

- 此檔案解決什麼問題
- 它負責什麼
- 它不負責什麼
- 它通常會被誰呼叫

---

## 0-2. 檔案類型判斷

請先判斷這個檔案主要屬於哪一種類型。  
如果同時符合多種類型，請列出「主要類型」與「次要類型」，但使用方式請以主要類型為主。
然後根據類型完成對應的文檔指引內容

### A. 頁面檔案 Page / Screen

常見特徵：

- 包含 Scaffold、AppBar、body
- 代表一個完整畫面
- 可能會被 Navigator、GoRouter 或 BottomNavigation 切換進入

使用方式應說明：

- 這個頁面怎麼進入
- 是否需要傳入參數
- 參數從哪裡來
- 是否需要先準備 Provider、Controller 或資料
- 是否會回傳結果給上一頁

請提供範例：

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ExamplePage(
      id: exampleId,
    ),
  ),
);
```

---

### B. 可重用 Widget 檔案 Reusable Widget / Component

常見特徵：

- 主要是一個 StatelessWidget 或 StatefulWidget
- 不代表完整頁面
- 目的是讓其他畫面重複使用

使用方式應說明：

- 這個 Widget 適合放在哪裡
- 父層需要傳入哪些參數
- 哪些參數是必填
- 哪些參數是選填
- callback 什麼時候會被觸發
- 這個 Widget 是否自己管理狀態

請提供參數表：

| 參數名稱 | 型別 | 必填 | 作用 | 注意事項 |
|---|---|---|---|---|
| title | String | 是 | 顯示標題 | 不建議傳入空字串 |
| onTap | VoidCallback? | 否 | 點擊時觸發 | 若為 null 則不執行點擊事件 |

請提供範例：

```dart
ExampleCard(
  title: '中央大學',
  subtitle: '校園導覽景點',
  onTap: () {
    // 點擊後執行導航或狀態更新
  },
);
```

---

### C. 狀態管理檔案 Controller / Provider / Bloc / ViewModel

常見特徵：

- 管理畫面狀態
- 包含 notifyListeners、emit、state、setState 以外的狀態更新邏輯
- 被 UI 呼叫，用來載入資料、更新資料或控制流程

使用方式應說明：

- 要如何建立或註冊
- UI 要如何讀取狀態
- UI 要如何呼叫方法
- 哪些方法需要 await
- 哪些方法會導致畫面更新
- 是否需要 dispose 或 reset

請提供狀態表：

| 狀態名稱 | 型別 | 初始值 | 改變時機 | UI 用途 |
|---|---|---|---|---|
| isLoading | bool | false | 載入資料時 | 控制 Loading 畫面 |
| items | List<Item> | [] | API 回傳後 | 顯示清單內容 |

請提供範例：

```dart
final controller = context.read<ExampleController>();
await controller.loadData();

final isLoading = context.watch<ExampleController>().isLoading;
```

---

### D. API / Service / Repository 檔案

常見特徵：

- 呼叫後端 API、Firebase、Supabase、Google Maps、NFC、定位或其他外部服務
- 方法通常會回傳 Future
- 常見命名包含 service、api、repository、client

使用方式應說明：

- 這個檔案負責呼叫哪一種資料來源
- 使用前是否需要初始化
- 每個公開方法怎麼呼叫
- 需要傳入什麼參數
- 會回傳什麼資料
- 可能發生什麼錯誤
- 呼叫端應該如何處理錯誤

請提供方法表：

| 方法名稱 | 作用 | 輸入 | 輸出 | 是否需要 await | 可能錯誤 |
|---|---|---|---|---|---|
| fetchData | 取得資料 | id: String | Future<DataModel> | 是 | 網路錯誤、資料不存在 |

請提供範例：

```dart
try {
  final data = await exampleService.fetchData(id);
} catch (e) {
  // 顯示錯誤訊息或進行重試
}
```

---

### E. Model / Data Class 檔案

常見特徵：

- 定義資料欄位
- 包含 fromJson、toJson、copyWith
- 用於 API、資料庫、本地 JSON 或畫面資料傳遞

使用方式應說明：

- 這個 Model 代表什麼資料
- 通常從哪裡產生
- 哪些欄位必填
- 哪些欄位可能為 null
- 如何從 JSON 建立
- 如何轉回 JSON

請提供欄位表：

| 欄位名稱 | 型別 | 是否可為 null | 作用 | 注意事項 |
|---|---|---|---|---|
| id | String | 否 | 唯一識別碼 | 不可為空 |
| name | String | 否 | 顯示名稱 | 建議不可為空字串 |

請提供範例：

```dart
final item = ExampleModel.fromJson(json);
final jsonData = item.toJson();
```

---

### F. 本地儲存檔案 Local Storage / Cache / Preferences

常見特徵：

- 使用 SharedPreferences、Hive、SQLite、SecureStorage
- 負責儲存 token、設定、快取或使用者本地資料

使用方式應說明：

- 這個檔案儲存哪些資料
- 每個 key 的用途
- 什麼時候讀取
- 什麼時候寫入
- 什麼時候清除
- App 重開後資料是否仍存在

請提供 key 表：

| Key | 型別 | 預設值 | 寫入時機 | 讀取時機 | 用途 |
|---|---|---|---|---|---|
| isFirstOpen | bool | true | 教學完成後 | App 啟動時 | 判斷是否顯示教學 |

請提供範例：

```dart
await localStorage.saveIsFirstOpen(false);
final isFirstOpen = await localStorage.getIsFirstOpen();
```

---

### G. 工具函數檔案 Utility / Helper / Extension

常見特徵：

- 提供格式轉換、計算、驗證、字串處理、日期處理
- 通常不直接操作 UI
- 多數情況下不保存狀態

使用方式應說明：

- 每個公開函數的用途
- 輸入是什麼
- 輸出是什麼
- 是否有副作用
- 常見邊界情況

請提供函數表：

| 函數名稱 | 作用 | 輸入 | 輸出 | 注意事項 |
|---|---|---|---|---|
| formatDistance | 格式化距離 | meter: double | String | meter 不應小於 0 |

請提供範例：

```dart
final text = formatDistance(350);
```

---

### H. 常數 / 主題 / 設定檔案 Constants / Theme / Config

常見特徵：

- 定義顏色、字體、尺寸、路徑、API base URL、全域設定
- 通常被很多檔案引用

使用方式應說明：

- 這些常數在哪裡被使用
- 使用時如何引用
- 修改後可能影響哪些地方
- 哪些值不建議隨意修改

請提供範例：

```dart
Container(
  color: AppColors.primary,
);
```

---

## 0-3. 輸出格式

請在和/home/a/for_coding/FOR_FLUTTER/flutter_projects/smart_school_pro/Campus-tour/campus_tour/test/Documentation_Guidelines.md所述的「同一個」文檔中依照以下格式輸出：

```md
# 檔案用途與使用方式

## 1. 檔案簡介

[用 3 到 5 句話說明此檔案解決什麼問題、負責什麼、不負責什麼、通常被誰呼叫。]

## 2. 檔案類型

- 主要類型：
- 次要類型：

## 3. 使用方式或呼叫方式

[根據檔案類型，說明這個檔案應該如何使用。]

## 4. 使用範例

```dart
// 請提供最小可用範例
```

## 5. 參數 / 方法 / 欄位說明

[依照檔案類型選擇合適的表格。]

## 6. 使用注意事項

- [是否需要 await]
- [是否需要初始化]
- [是否可能為 null]
- [是否會觸發畫面更新]
- [是否需要權限或網路]
- [是否需要 dispose]
```

---

## 0-4. 補充規則

- 請優先說明 public class、public method、constructor parameter 的使用方式。
- private method 只需要說明它在內部被誰呼叫，不需要提供外部使用範例。
- 如果是 Widget，請重點說明 constructor 參數與 callback。
- 如果是 Service，請重點說明 async 呼叫方式、輸入、輸出與錯誤處理。
- 如果是 Controller，請重點說明 UI 如何讀取狀態與呼叫方法。
- 如果是 Model，請重點說明欄位、fromJson、toJson。
- 如果是本地儲存，請重點說明 key、讀取、寫入、清除。
- 如果是工具函數，請重點說明 input、output 與邊界情況。
- 不要撰寫過度抽象的架構說明。
- 不要重複描述已經在邏輯對照表中會出現的細節。
- 不要把每一行程式碼都重新解釋一次，此處只說明「怎麼用」。
