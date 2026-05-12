# strategy_book_level_page.dart 邏輯追蹤表

## 目前版本邏輯對照表

<table>
  <thead>
    <tr>
      <th>ID</th>
      <th>目的標籤</th>
      <th>邏輯描述</th>
      <th>函數為單位</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>[L-01]</td>
      <td>目的[Overlay UI 建構]</td>
      <td>回傳可放入 <code>showGeneralDialog</code>[Flutter Dialog API] 的攻略秘集內容，使用 <code>level</code>[來自建構子] 與 <code>nextFunction</code>[來自建構子 callback] 建立含 Material 環境、置中且可捲動的彈窗；結構見 <a href="#build-widget-tree">Build Widget 結構圖</a>。</td>
      <td>【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>context: BuildContext</code>，提供 Widget 建構環境。<br>Process: 建立透明 Material、安全區、置中容器與捲動容器，讓彈窗疊在原本掃描關卡上，並讓 FilledButton 具備 Material ancestor。<br>回傳 Widget: 見 <a href="#build-widget-tree">Build Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-02]</td>
      <td>目的[視窗內容]</td>
      <td>建立彈窗卡片，顯示 <code>level.title</code>[來自建構子 level]、攻略秘集圖片區與繼續按鈕；結構見 <a href="#dialog-card-widget-tree">Dialog Card Widget 結構圖</a>。</td>
      <td>【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: 無顯式參數，讀取 <code>level</code>[來自建構子]。<br>Process: 將標題、帶疊字圖片與按鈕組合成單一彈窗卡片。<br>回傳 Widget: 見 <a href="#dialog-card-widget-tree">Dialog Card Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-03]</td>
      <td>目的[邊界檢查]</td>
      <td>檢查 <code>imagePath</code>[區域變數，來自 <code>level.imagePath.trim()</code>] 是否為空字串；若為空則以 fallback 作為圖片內容，並仍交給外層圖片框顯示疊字。</td>
      <td rowspan="2">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: 無顯式參數，讀取 <code>level.imagePath</code>[來自建構子 level]。<br>Process: 清理圖片路徑；空路徑時使用 fallback；有效路徑時建立 asset 圖片，載入失敗也使用 fallback。<br>回傳 Widget: 見 <a href="#strategy-book-image-widget-tree">Strategy Book Image Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-04]</td>
      <td>目的[圖片載入]</td>
      <td>使用 <code>imagePath</code>[區域變數] 建立攻略秘集資產圖片，並在 <code>errorBuilder</code>[Image.asset callback] 中呼叫 <code>_buildImageFallback()</code>[本類別方法] 處理載入失敗。</td>
    </tr>
    <tr>
      <td>[L-05]</td>
      <td>目的[疊字呈現]</td>
      <td>建立攻略秘集圖片框，將 <code>child</code>[參數] 作為底層圖片或 fallback，並在上方疊加 <code>level.noteText</code>[來自建構子 level]，顯示「詳見金屬指示牌」。</td>
      <td>【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>child: Widget</code>，代表圖片或 fallback 內容。<br>Process: 以 Stack 疊合圖片內容與上方提示文字。<br>回傳 Widget: 見 <a href="#book-image-frame-widget-tree">Book Image Frame Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-06]</td>
      <td>目的[流程推進]</td>
      <td>建立按鈕，顯示 <code>level.buttonText</code>[來自建構子 level]；使用者點擊時呼叫 <code>nextFunction</code>[來自建構子 callback]，讓外層 dialog 關閉並繼續任務。</td>
      <td>【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: 無顯式參數，讀取 <code>level.buttonText</code>[來自建構子 level] 與 <code>nextFunction</code>[來自建構子 callback]。<br>Process: 將按鈕文字與任務推進 callback 綁定到主要操作按鈕。<br>回傳 Widget: 見 <a href="#continue-button-widget-tree">Continue Button Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-07]</td>
      <td>目的[異常替代 UI]</td>
      <td>建立攻略秘集圖片缺失或載入失敗時的替代 UI，使用固定圖示提示此區原本應顯示書本圖片；結構見 <a href="#image-fallback-widget-tree">Image Fallback Widget 結構圖</a>。</td>
      <td>【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: 無。<br>Process: 建立圖片 fallback 容器與書本圖示，讓缺圖狀態仍可穩定渲染。<br>回傳 Widget: 見 <a href="#image-fallback-widget-tree">Image Fallback Widget 結構圖</a>。</td>
    </tr>
  </tbody>
</table>

## Widget 視覺化結構圖

### <a id="build-widget-tree"></a>Build Widget 結構圖

Material // [L-01]  
└── SafeArea  
&nbsp;&nbsp;&nbsp;&nbsp;└── Center  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── SingleChildScrollView (捲動頁面)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Dialog Card (視窗卡片) // [L-02]

### <a id="dialog-card-widget-tree"></a>Dialog Card Widget 結構圖

Container // [L-02]  
└── Column (垂直容器)  
&nbsp;&nbsp;&nbsp;&nbsp;├── Text (標題文字)  
&nbsp;&nbsp;&nbsp;&nbsp;├── Strategy Book Image (攻略秘集圖片) // [L-03][L-04]  
&nbsp;&nbsp;&nbsp;&nbsp;└── Continue Button (繼續按鈕) // [L-06]

### <a id="strategy-book-image-widget-tree"></a>Strategy Book Image Widget 結構圖

{ IF: imagePath.isEmpty } // [L-03]  
└── Book Image Frame (圖片疊字框) // [L-05]  
&nbsp;&nbsp;&nbsp;&nbsp;└── Image Fallback (缺圖替代) // [L-07]  
{ ELSE }  
└── Book Image Frame (圖片疊字框) // [L-05]  
&nbsp;&nbsp;&nbsp;&nbsp;└── Image.asset (資產圖片) // [L-04]

### <a id="book-image-frame-widget-tree"></a>Book Image Frame Widget 結構圖

Container // [L-05]  
└── Stack (堆疊容器)  
&nbsp;&nbsp;&nbsp;&nbsp;├── child (圖片內容)  
&nbsp;&nbsp;&nbsp;&nbsp;└── Align (上方對齊容器)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Text (提示文字)

### <a id="continue-button-widget-tree"></a>Continue Button Widget 結構圖

SizedBox // [L-06]  
└── FilledButton (主要操作按鈕)  
&nbsp;&nbsp;&nbsp;&nbsp;└── Text (按鈕文字)

### <a id="image-fallback-widget-tree"></a>Image Fallback Widget 結構圖

Container // [L-07]  
└── Icon (缺圖圖示)

## 場景時序圖

```mermaid
sequenceDiagram
  participant GraphicsPage as GraphicsTextLevelPage
  participant Dialog as StrategyBookLevelPage
  participant User as 使用者

  GraphicsPage->>Dialog: showGeneralDialog 建立疊加彈窗 [L-01]
  Dialog->>Dialog: 建立彈窗卡片 [L-02]
  Dialog->>Dialog: 檢查圖片路徑 [L-03]
  alt 圖片路徑有效
    Dialog->>Dialog: 顯示攻略秘集圖片 [L-04]
  else 圖片路徑空白或載入失敗
    Dialog->>Dialog: 顯示 fallback [L-07]
  end
  Dialog->>Dialog: 在圖片上方疊加 noteText [L-05]
  User->>Dialog: 點擊「好好研究它」
  Dialog->>GraphicsPage: 呼叫 nextFunction 繼續掃描關卡後續流程 [L-06]
```

## 測資建議表

| ID | 測試時應輸入的極端值或狀態 |
| --- | --- |
| [L-01] | 使用極小螢幕高度渲染 dialog，確認內容可捲動、FilledButton 不缺 Material ancestor，且不 overflow。 |
| [L-02] | 傳入很長的 <code>level.title</code>，確認標題仍在視窗卡片內換行。 |
| [L-03] | 傳入空字串或只有空白的 <code>level.imagePath</code>，確認仍顯示帶疊字的 fallback。 |
| [L-04] | 傳入不存在的 asset 路徑，確認 <code>errorBuilder</code> 會顯示 fallback。 |
| [L-05] | 傳入超長 <code>level.noteText</code>，確認疊字區可讀且位於圖片上方。 |
| [L-06] | 點擊按鈕，確認外層 callback 被呼叫並能讓任務繼續。 |
| [L-07] | 強制圖片載入失敗，確認 fallback 圖示能獨立渲染。 |
