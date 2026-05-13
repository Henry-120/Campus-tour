# novice_leading_page.dart 邏輯追蹤表

## 邏輯對照表

<table>
  <thead>
    <tr>
      <th>ID</th>
      <th>目的標籤</th>
      <th>邏輯描述</th>
      <th>測資建議</th>
      <th>函數為單位</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>[L-01]</td>
      <td>[資料初始化]</td>
      <td>建立 <code>_steps</code> [來自 State 靜態常數]，依序保存 10 頁新手教學資料；圖片路徑全部使用 <code>assets/images/novice_leading/</code> 格式，並用 <code>textAlignment</code> [來自資料模型] 避開主要發光提示區。</td>
      <td>確認清單長度為 10，且每個圖片步驟的 <code>imageAsset</code> 都能被 Flutter asset bundle 找到。</td>
      <td rowspan="1">【資料建構】(Data Transformer)<br>Input: 無。<br>Process: 將固定教學順序轉成 <code>List&lt;_NoviceLeadingStep&gt;</code>。<br>Output: <code>_steps</code> [List&lt;_NoviceLeadingStep&gt;]。</td>
    </tr>
    <tr>
      <td>[L-02]</td>
      <td>[狀態初始化]</td>
      <td>建立 <code>_pageController</code> [來自 State 欄位] 控制翻頁動畫，並以 <code>_currentIndex</code> [來自 State 欄位] 記錄目前頁碼。</td>
      <td>頁面首次建立時確認 <code>_currentIndex = 0</code>，且第一張圖片為 squirrel.JPG。</td>
      <td rowspan="2">【生命週期函數】(Action Performer)<br>Purpose: 狀態初始化/資源釋放。<br>Action: 建立 PageController；頁面 dispose 時釋放 controller。</td>
    </tr>
    <tr>
      <td>[L-03]</td>
      <td>[資源釋放]</td>
      <td>在 <code>dispose</code> 釋放 <code>_pageController</code> [來自 State 欄位]，避免頁面移除後仍保留動畫控制資源。</td>
      <td>進入教學頁後立即 pop，確認沒有 PageController disposed 相關例外。</td>
    </tr>
    <tr>
      <td>[L-04]</td>
      <td>[UI 架構]</td>
      <td><code>build</code> 回傳全屏 <code>Scaffold</code>，主要結構為可點擊的翻頁教學畫面；視覺結構見 <a href="#visual-a-build">視覺化結構圖 A</a>。</td>
      <td>用 360x800 與 1080x2400 螢幕測試，確認畫面滿版且不出現白邊。</td>
      <td rowspan="7">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>context</code> [來自 Flutter build 參數]、<code>_currentIndex</code> [來自 State 欄位]、<code>_steps</code> [來自 State 靜態常數]。<br>Process: 建立全屏 Stack；PageView 依 index 回傳對應頁面；控制列依目前頁碼顯示或停用。<br>Output: <code>Widget</code>，主要結構見 <a href="#visual-a-build">視覺化結構圖 A</a>。</td>
    </tr>
    <tr>
      <td>[L-05]</td>
      <td>[互動推進]</td>
      <td>將全屏點擊事件綁定到 <code>_handlePageTap</code> [來自 State 方法]，讓使用者點擊非功能文字區域時前往下一步。</td>
      <td>點擊圖片空白區確認會下一頁；點擊「跳過」或「上一步」時確認只執行該按鈕功能。</td>
    </tr>
    <tr>
      <td>[L-06]</td>
      <td>[翻頁容器]</td>
      <td>使用 <code>PageView.builder</code> 依 <code>_steps.length</code> [來自 State 靜態常數] 建立翻書式頁面。</td>
      <td>快速左右滑動多頁，確認頁數不會超出 0 到 9。</td>
    </tr>
    <tr>
      <td>[L-07]</td>
      <td>[狀態同步]</td>
      <td>PageView 頁碼改變時呼叫 <code>_updateCurrentIndex</code> [來自 State 方法]，同步底部控制列與跳過按鈕狀態。</td>
      <td>滑到最後一頁，確認「下一步」與「跳過」隱藏，只保留結束教學按鈕。</td>
    </tr>
    <tr>
      <td>[L-08]</td>
      <td>[頁面生成]</td>
      <td>用 <code>index</code> [來自 PageView.builder 區域變數] 取出 <code>_steps[index]</code> [來自 State 靜態常數]，並交給 <code>_buildStepPage</code> 分派。</td>
      <td>將 index 測到 0、5、9，確認分別建立圖片頁、plot 頁、結束頁。</td>
    </tr>
    <tr>
      <td>[L-09]</td>
      <td>[導航控制]</td>
      <td>疊上右上角「跳過」按鈕，按鈕顯示邏輯由 <code>_isLastPage</code> [來自 State getter] 決定。</td>
      <td>在第 9 頁前都應顯示跳過；第 10 頁應隱藏。</td>
    </tr>
    <tr>
      <td>[L-10]</td>
      <td>[導航控制]</td>
      <td>疊上底部「上一步」與「下一步」控制列，依 <code>_currentIndex</code> [來自 State 欄位] 停用或隱藏按鈕。</td>
      <td>第一頁「上一步」不可用；最後一頁「下一步」不可見。</td>
    </tr>
    <tr>
      <td>[L-11]</td>
      <td>[頁型分派]</td>
      <td>根據 <code>step.kind</code> [來自參數 _NoviceLeadingStep] 分派到圖片頁、plot_level 感頁或結束頁；視覺結構見 <a href="#visual-b-step-dispatch">視覺化結構圖 B</a>。</td>
      <td>傳入三種 <code>_NoviceLeadingStepKind</code>，確認都能回傳非 null Widget。</td>
      <td rowspan="1">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>step</code> [_NoviceLeadingStep，來自呼叫端]。<br>Process: 依 <code>step.kind</code> 選擇對應頁面建構函數。<br>Output: <code>Widget</code>，分派結果見 <a href="#visual-b-step-dispatch">視覺化結構圖 B</a>。</td>
    </tr>
    <tr>
      <td>[L-12]</td>
      <td>[圖片教學]</td>
      <td>圖片頁用 <code>step.imageAsset</code> [來自參數資料模型] 滿版顯示圖片，再疊上漸層與 <code>step.message</code> [來自參數資料模型] 說明文字；視覺結構見 <a href="#visual-c-image-page">視覺化結構圖 C</a>。</td>
      <td>刪除或拼錯其中一張圖片路徑，確認測試能捕捉 asset 載入錯誤。</td>
      <td rowspan="1">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>step</code> [_NoviceLeadingStep，來自呼叫端]。<br>Process: 使用圖片資產作背景，並依 <code>textAlignment</code> 疊放文字面板。<br>Output: <code>Widget</code>，結構見 <a href="#visual-c-image-page">視覺化結構圖 C</a>。</td>
    </tr>
    <tr>
      <td>[L-13]</td>
      <td>[劇情提示]</td>
      <td>建立 plot_level 感的純文字過場頁，顯示 <code>step.message</code> [來自參數資料模型]「更多精采體驗等著你器探索」；視覺結構見 <a href="#visual-d-plot-page">視覺化結構圖 D</a>。</td>
      <td>從第 5 頁點下一步，確認第 6 頁不是圖片頁且文字置中。</td>
      <td rowspan="1">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>step</code> [_NoviceLeadingStep，來自呼叫端]。<br>Process: 將過場訊息放入劇情式背景頁。<br>Output: <code>Widget</code>，結構見 <a href="#visual-d-plot-page">視覺化結構圖 D</a>。</td>
    </tr>
    <tr>
      <td>[L-14]</td>
      <td>[結束頁]</td>
      <td>建立最後一頁，顯示 <code>step.message</code> [來自參數資料模型] 與「結束教學」按鈕；視覺結構見 <a href="#visual-e-finish-page">視覺化結構圖 E</a>。</td>
      <td>滑到第 10 頁，確認點擊頁面空白處不會自動結束，必須點按鈕。</td>
      <td rowspan="2">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>step</code> [_NoviceLeadingStep，來自呼叫端]。<br>Process: 顯示結束文案與可完成教學的按鈕。<br>Output: <code>Widget</code>，結構見 <a href="#visual-e-finish-page">視覺化結構圖 E</a>。</td>
    </tr>
    <tr>
      <td>[L-15]</td>
      <td>[完成教學]</td>
      <td>「結束教學」按鈕呼叫 <code>_finishTutorial</code> [來自 State 方法]，結束整段新手教學。</td>
      <td>提供 <code>onFinish</code> [來自建構子] mock callback，確認點擊後 callback 執行一次。</td>
    </tr>
    <tr>
      <td>[L-16]</td>
      <td>[邊界檢查]</td>
      <td>若 <code>_isLastPage</code> [來自 State getter] 為 true，右上角跳過按鈕回傳空 Widget，避免最後頁同時出現跳過與結束教學。</td>
      <td>把 <code>_currentIndex</code> 設為 9，確認找不到「跳過」。</td>
      <td rowspan="2">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>_currentIndex</code> [來自 State 欄位]。<br>Process: 最後頁隱藏，其他頁顯示右上角文字按鈕。<br>Output: <code>Widget</code>，控制區見 <a href="#visual-f-controls">視覺化結構圖 F</a>。</td>
    </tr>
    <tr>
      <td>[L-17]</td>
      <td>[略過流程]</td>
      <td>「跳過」按鈕呼叫 <code>_finishTutorial</code> [來自 State 方法]，直接結束教學。</td>
      <td>任一非最後頁點擊「跳過」，確認不再進行翻頁動畫並完成流程。</td>
    </tr>
    <tr>
      <td>[L-18]</td>
      <td>[控制列建立]</td>
      <td>建立底部控制列，承載「上一步」與「下一步」功能文字；視覺結構見 <a href="#visual-f-controls">視覺化結構圖 F</a>。</td>
      <td>在窄螢幕確認兩個文字按鈕不重疊。</td>
      <td rowspan="3">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>_currentIndex</code> [來自 State 欄位]、<code>_isLastPage</code> [來自 State getter]。<br>Process: 第一頁停用上一步；最後頁隱藏下一步；中間頁提供雙向導航。<br>Output: <code>Widget</code>，控制區見 <a href="#visual-f-controls">視覺化結構圖 F</a>。</td>
    </tr>
    <tr>
      <td>[L-19]</td>
      <td>[邊界檢查]</td>
      <td>當 <code>_currentIndex</code> [來自 State 欄位] 為 0 時停用「上一步」，避免往負頁碼移動。</td>
      <td>第一頁點擊「上一步」位置，確認頁碼仍為 0。</td>
    </tr>
    <tr>
      <td>[L-20]</td>
      <td>[下一步導航]</td>
      <td>非最後頁顯示「下一步」，點擊後呼叫 <code>_goNext</code> [來自 State 方法]。</td>
      <td>第 8 頁點「下一步」到第 9 頁；第 10 頁應不存在此按鈕。</td>
    </tr>
    <tr>
      <td>[L-21]</td>
      <td>[點擊推進]</td>
      <td>全屏點擊時先檢查 <code>_isLastPage</code> [來自 State getter]，最後頁不自動完成；非最後頁呼叫 <code>_goNext</code>。</td>
      <td>最後頁點擊空白處，確認沒有 pop；第 1 頁點擊空白處，確認前往第 2 頁。</td>
      <td rowspan="1">【功能函數】(Action Performer)<br>Purpose: 互動推進/邊界檢查。<br>Action: 若不是最後頁，委派下一步導航；最後頁直接返回。</td>
    </tr>
    <tr>
      <td>[L-22]</td>
      <td>[下一步導航]</td>
      <td><code>_goNext</code> 檢查 <code>_isLastPage</code> [來自 State getter]，合法時以 <code>_currentIndex + 1</code> [來自 State 欄位計算值] 前進。</td>
      <td>倒數第二頁呼叫後應到最後頁；最後頁呼叫後不應越界。</td>
      <td rowspan="1">【功能函數】(Action Performer)<br>Purpose: 導航/邊界檢查。<br>Action: 檢查最後頁；呼叫 <code>_goToPage</code> 前往下一頁。</td>
    </tr>
    <tr>
      <td>[L-23]</td>
      <td>[上一步導航]</td>
      <td><code>_goPrevious</code> 檢查 <code>_currentIndex</code> [來自 State 欄位] 是否為 0，合法時以前一頁為目標。</td>
      <td>第二頁呼叫後回第一頁；第一頁呼叫後不應越界。</td>
      <td rowspan="1">【功能函數】(Action Performer)<br>Purpose: 導航/邊界檢查。<br>Action: 檢查第一頁；呼叫 <code>_goToPage</code> 回上一頁。</td>
    </tr>
    <tr>
      <td>[L-24]</td>
      <td>[翻頁動畫]</td>
      <td><code>_goToPage</code> 將 <code>index</code> [來自函數參數] 夾在 0 到 <code>_steps.length - 1</code> [來自 State 靜態常數]，再用 <code>_pageController</code> [來自 State 欄位] 執行翻頁動畫。</td>
      <td>傳入 -99 與 999，確認目標頁被限制在 0 與 9。</td>
      <td rowspan="1">【功能函數】(Action Performer)<br>Purpose: 翻頁動畫/邊界檢查。<br>Action: clamp 目標頁；呼叫 PageController.animateToPage。</td>
    </tr>
    <tr>
      <td>[L-25]</td>
      <td>[狀態更新]</td>
      <td><code>_updateCurrentIndex</code> 將 <code>index</code> [來自 PageView callback] 寫入 <code>_currentIndex</code> [來自 State 欄位]，觸發控制列重建。</td>
      <td>滑動頁面後確認底部按鈕狀態跟著更新。</td>
      <td rowspan="1">【功能函數】(Action Performer)<br>Purpose: 狀態更新/UI 同步。<br>Action: setState 更新目前頁碼。</td>
    </tr>
    <tr>
      <td>[L-26]</td>
      <td>[完成回呼]</td>
      <td><code>_finishTutorial</code> 優先檢查 <code>widget.onFinish</code> [來自建構子]，若存在就執行外部完成邏輯並返回。</td>
      <td>傳入 callback 並點擊「跳過」，確認 callback 執行且沒有 Navigator pop。</td>
      <td rowspan="2">【功能函數】(Action Performer)<br>Purpose: 完成教學/導航回退。<br>Action: 優先執行外部 onFinish；未提供時嘗試 Navigator.maybePop。</td>
    </tr>
    <tr>
      <td>[L-27]</td>
      <td>[預設退出]</td>
      <td>未提供 <code>onFinish</code> [來自建構子] 時，呼叫 <code>Navigator.maybePop(context)</code> [context 來自 State] 作為預設結束行為。</td>
      <td>用 Navigator 包住頁面且不傳 callback，點擊結束後確認 route 被 pop。</td>
    </tr>
    <tr>
      <td>[L-28]</td>
      <td>[狀態判斷]</td>
      <td><code>_isLastPage</code> 比對 <code>_currentIndex</code> [來自 State 欄位] 與 <code>_steps.length - 1</code> [來自 State 靜態常數]，回傳是否已在最後一頁。</td>
      <td>分別設定頁碼 8 與 9，確認只在 9 回傳 true。</td>
      <td rowspan="1">【回傳函數】(Data Transformer)<br>Input: <code>_currentIndex</code> [int，來自 State 欄位]、<code>_steps.length</code> [int，來自 State 靜態常數]。<br>Process: 比對目前頁碼是否等於最後索引。<br>Output: <code>bool</code>。</td>
    </tr>
    <tr>
      <td>[L-29]</td>
      <td>[文字面板]</td>
      <td><code>_InstructionPanel.build</code> 顯示 <code>message</code> [來自建構子]，作為圖片上方疊字面板；視覺結構見 <a href="#visual-g-instruction-panel">視覺化結構圖 G</a>。</td>
      <td>輸入長句與空字串，確認不溢出且空字串不造成例外。</td>
      <td rowspan="1">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>message</code> [String，來自建構子]。<br>Process: 建立文字容器並置入教學訊息。<br>Output: <code>Widget</code>，結構見 <a href="#visual-g-instruction-panel">視覺化結構圖 G</a>。</td>
    </tr>
  </tbody>
</table>

## 視覺化結構圖

### Visual A Build
<a id="visual-a-build"></a>

[Scaffold (頁面骨架)]  
└── [GestureDetector (全屏點擊區)] // [L-05]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [Stack (疊層容器)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── [PageView.builder (翻頁容器)] // [L-06]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── [_buildStepPage (頁型分派)] // [L-08]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── [_buildSkipButton (跳過按鈕)] // [L-09]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [_buildNavigationButtons (底部導航)] // [L-10]

### Visual B Step Dispatch
<a id="visual-b-step-dispatch"></a>

[_buildStepPage (頁型分派)] // [L-11]  
├── [_buildImagePage (圖片教學頁)]  
├── [_buildPlotLevelPage (劇情過場頁)]  
└── [_buildFinishPage (結束教學頁)]

### Visual C Image Page
<a id="visual-c-image-page"></a>

[Stack (疊層容器)] // [L-12]  
├── [Image.asset (圖片背景)]  
├── [DecoratedBox (遮罩圖層)]  
└── [Align (文字定位)]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [Padding (文字外距)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [_InstructionPanel (教學文字面板)]

### Visual D Plot Page
<a id="visual-d-plot-page"></a>

[DecoratedBox (劇情背景)] // [L-13]  
└── [SafeArea (安全區域)]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [Center (置中容器)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [Padding (文字外距)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [Text (劇情提示文字)]

### Visual E Finish Page
<a id="visual-e-finish-page"></a>

[DecoratedBox (結束背景)] // [L-14]  
└── [SafeArea (安全區域)]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [Center (置中容器)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [Padding (內容外距)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [Column (垂直容器)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── [Text (結束提示文字)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [ElevatedButton (結束教學按鈕)] // [L-15]

### Visual F Controls
<a id="visual-f-controls"></a>

[SafeArea (安全區域)] // [L-16] [L-18]  
├── [Align (右上定位)]  
│&nbsp;&nbsp;&nbsp;&nbsp;└── [TextButton (跳過)] // [L-17]  
└── [Align (底部定位)]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [Row (水平導航列)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── [TextButton (上一步)] // [L-19]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [TextButton (下一步)] // [L-20]

### Visual G Instruction Panel
<a id="visual-g-instruction-panel"></a>

[DecoratedBox (文字面板)] // [L-29]  
└── [Padding (文字內距)]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [Text (教學文字)]

## 使用者情境時序圖

情境 A [一般完成教學]：使用者進入 `NoviceLeadingPage` -> [L-01] -> [L-04] -> [L-06] -> [L-08] -> [L-11] -> 使用者點擊任意非功能文字區域 -> [L-21] -> [L-22] -> [L-24] -> [L-25] -> 重複至最後頁 -> [L-14] -> 點擊「結束教學」 -> [L-15] -> [L-26] 或 [L-27] 結束

情境 B [使用下一步與上一步]：使用者點擊「下一步」 -> [L-20] -> [L-22] -> [L-24] -> [L-25] -> 使用者點擊「上一步」 -> [L-19] -> [L-23] -> [L-24] -> [L-25] 結束

情境 C [略過教學]：使用者在非最後頁點擊「跳過」 -> [L-16] -> [L-17] -> [L-26] 或 [L-27] 結束

情境 D [最後頁空白點擊]：使用者到達最後頁 -> [L-25] -> [L-28] -> 點擊空白區域 -> [L-21] -> 停留在最後頁 -> 點擊「結束教學」 -> [L-15] -> [L-26] 或 [L-27] 結束
