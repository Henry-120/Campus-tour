# Role: 你現在是一名資深「Flutter 系統架構審計師」。

Context: 我正在進行一個大型協作專案，需要建立代碼邏輯與文檔的強連結。我會提供一段程式碼，請你進行解構並同步完成標記。

## Task 0: 檔案用途與使用方式
請參考/home/a/for_coding/FOR_FLUTTER/flutter_projects/smart_school_pro/Campus-tour/campus_tour/test/Documentation_Guidelines_2.md內的內容完成


## Task 1: 邏輯拆解與文檔寫入
#### 請在專案目錄下我指定的文件中，針對指定的程式碼完成以下內容，內容包含：

邏輯對照表 (Table):

- ID: 格式為 [L-XX]。

- 目的標籤： 在邏輯描述前加上「目的」，例如 [安全性檢查], [效能優化], [UI 反饋]等......。

- 邏輯描述: 精簡說明該步驟的作用（包含邊界檢查、非同步等待、異常捕獲等）


所以理論上會有3個欄位，ID 、 目的標籤 、 邏輯描述 

#### 務必注意

- 在「邏輯對照表」中，若提到任何變數，必須標註其來源（例如：[來自建構子], [來自 Provider/Bloc], [區域變數]）。

#### 視覺化結構圖:
[根 Widget]  
└── [容器 Widget]  
&nbsp;&nbsp;&nbsp;&nbsp;├── [子 Widget] // [L-XX]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [子 Widget]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── { IF: isLoading } // [L-06]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│   └── [CircularProgressIndicator] 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── { ELSE }
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    └── [EmptyStateWidget] // [L-07]

- 禁令： 禁止放入任何樣式屬性 (padding, color, decoration, size)。
- 僅保留 Widget 功能 : 像是[捲動頁面] 、 [橫向容器]等，務必英文後面要括號中文


## Task 2: 代碼原地標記 (In-place Annotation)
請直接修改我提供的程式碼，要求如下：

- 在每一條邏輯對應的程式碼行上方，插入對應的 ID 註解（Flutter 使用 // [L-XX]）。

- 嚴禁改變原本的程式碼邏輯，僅限增加註解。

- 確保 ID 註解的位置精確對準邏輯判斷式或函數調用處。

## Task 3: 函數為單位對照表
- 函數名稱
- 目的標籤： 在邏輯描述前加上「目的」，例如 [安全性檢查], [效能優化], [UI 反饋]等......。
- 包含範圍 : 假設該函數包含[L-01] ~ [L-05]，請在這欄內列出包含的編號
-  函數功能介紹 : 務必參考注意事項所寫

所以理論上會有3個欄位，函數名稱 、 包含範圍 、 函數功能介紹 

### 注意事項
- 函數單位介紹規則指引，請在文檔中，根據函數類型使用以下格式進行總結：
  - 【回傳函數】(Data Transformer):(除了 Widget 返回函數)
    - Input: [變數名與型別與該input功能]
    - Process: [核心演算法/轉換邏輯]
    - Output: [結果值與型別]
  - 【功能函數】(Action Performer):
    - Purpose: [目的標籤，例如：安全性檢查/導航/狀態更新]
    - Action: [具體執行的動作清單，務必要詳細說明]
  - 【兼用函數】(Hybrid): 
    - 結合上述兩者。
  - 【Build 函數 / Widget 返回函數】(UI Tree): 
    - Input: [變數名與型別與該input功能] (如果有)
    - Process: [核心演算法/轉換邏輯] : 請將邏輯判斷部份寫在這裡
    - 請將回傳的widget使用以下視覺化結構表達另外放在邏輯對照表"外面的下方"並提供超連結指向，請不要直接將圖放在表格內。

## Task 4: 場景時序圖 (Scenario Timing)
為了表達跨檔案或非同步的執行順序，請根據代碼邏輯歸納出「使用者情境」的執行流：
請以 Mermaid Sequence Diagram 格式輸出

<!-- 情境 A [情境名稱]： 觸發源 -> [L-01] -> [L-05] -> [L-02] 結束

情境 B [情境名稱]： ... -->


## Task 5: 測資建議表
針對task 2 的每個 ID，建議一個測試時應輸入的極端值或狀態。並做成表格
