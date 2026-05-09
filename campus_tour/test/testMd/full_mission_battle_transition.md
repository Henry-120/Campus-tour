# battle_start_transition.dart 邏輯追蹤表

> 本文件依據 `Documentation_Guidelines.md` 新版格式撰寫，對應 `battle_start_transition.dart` 中 `[L-01]` ~ `[L-36]` 原地標記。此版本已移除箭頭 UI，並將上方面板背景色改為精靈屬性配色、下方面板改為 AppTheme 暖色系。

## 目前版本邏輯對照表

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
      <td>[動畫初始化]</td>
      <td>建立 <code>_controller</code>[State 欄位]，以 <code>this</code>[TickerProvider] 驅動 620ms 的關門與開門動畫。</td>
      <td>pump widget 後確認控制器可 forward/reverse，且 duration 為 620ms。</td>
      <td rowspan="3">【功能函數】(Action Performer)<br>Purpose: [動畫初始化/非同步啟動]<br>Action: 建立 AnimationController；包裝成 easeInOutCubic 動畫曲線；使用 unawaited 啟動完整轉場流程，避免 initState 等待動畫完成。</td>
    </tr>
    <tr>
      <td>[L-02]</td>
      <td>[動畫曲線]</td>
      <td>使用 <code>_controller</code>[State 欄位] 建立 <code>_curve</code>[State 欄位]，讓面板滑動具有加減速。</td>
      <td>在動畫中段檢查 progress，確認曲線不是線性變化。</td>
    </tr>
    <tr>
      <td>[L-03]</td>
      <td>[非同步啟動]</td>
      <td>呼叫 <code>unawaited(_runTransition())</code>[dart:async API 與 State 方法]，讓轉場流程背景執行。</td>
      <td>建立 widget 後立即 pump，確認 build 不等待動畫完成。</td>
    </tr>
    <tr>
      <td>[L-04]</td>
      <td>[資源釋放]</td>
      <td>釋放 <code>_controller</code>[State 欄位]，避免 overlay 卸載後留下 active ticker。</td>
      <td>動畫進行中移除 widget，確認測試沒有 ticker leak 警告。</td>
      <td>【功能函數】(Action Performer)<br>Purpose: [資源釋放]<br>Action: 在 dispose 階段釋放 AnimationController，接著呼叫父類 dispose 完成 State 清理。</td>
    </tr>
    <tr>
      <td>[L-05]</td>
      <td>[關門動畫]</td>
      <td>等待 <code>_controller.forward()</code>[State 欄位控制器] 完成，代表兩片面板完全閉合。</td>
      <td>pump 少於 620ms 時確認尚未呼叫 onClosed；pump 到 620ms 後才呼叫。</td>
      <td rowspan="8">【功能函數】(Action Performer)<br>Purpose: [轉場時序/非同步等待/生命週期防護]<br>Action: 播放關門動畫；每個非同步階段後檢查 mounted；完全閉合後通知父層切換底頁；停留 200ms 遮住切頁；反向播放開門動畫；最後通知父層移除 overlay。</td>
    </tr>
    <tr>
      <td>[L-06]</td>
      <td>[生命週期防護]</td>
      <td>forward 完成後檢查 <code>mounted</code>[State 生命週期屬性]，若 overlay 已卸載則中止流程。</td>
      <td>關門動畫途中 pop 頁面，確認不呼叫 onClosed。</td>
    </tr>
    <tr>
      <td>[L-07]</td>
      <td>[閉合回呼]</td>
      <td>呼叫 <code>_callClosedOnce()</code>[State 方法]，在畫面被面板完全蓋住時通知父層切換底層 mission。</td>
      <td>確認 onClosed 執行時動畫已到完全閉合狀態。</td>
    </tr>
    <tr>
      <td>[L-08]</td>
      <td>[視覺停留]</td>
      <td>等待 200ms[區域常量 Duration]，讓閉合畫面短暫停留以遮住底層頁面切換。</td>
      <td>使用 fakeAsync 驗證 reverse 不會在 onClosed 後立刻開始。</td>
    </tr>
    <tr>
      <td>[L-09]</td>
      <td>[生命週期防護]</td>
      <td>停留後再次檢查 <code>mounted</code>[State 生命週期屬性]，避免卸載後繼續反向動畫。</td>
      <td>閉合停留期間移除 widget，確認不執行 reverse。</td>
    </tr>
    <tr>
      <td>[L-10]</td>
      <td>[開門動畫]</td>
      <td>等待 <code>_controller.reverse()</code>[State 欄位控制器] 完成，讓面板原路滑出並露出新頁面。</td>
      <td>onClosed 後 pump reverse duration，確認底層 CryptographyLevelPage 被露出。</td>
    </tr>
    <tr>
      <td>[L-11]</td>
      <td>[生命週期防護]</td>
      <td>reverse 完成後檢查 <code>mounted</code>[State 生命週期屬性]，避免卸載後呼叫完成 callback。</td>
      <td>開門動畫途中 pop 頁面，確認不呼叫 onFinished。</td>
    </tr>
    <tr>
      <td>[L-12]</td>
      <td>[完成回呼]</td>
      <td>呼叫 <code>_callFinishedOnce()</code>[State 方法]，通知父層移除 overlay 並解除轉場鎖。</td>
      <td>完整動畫結束後確認 onFinished 只執行一次。</td>
    </tr>
    <tr>
      <td>[L-13]</td>
      <td>[重入防護]</td>
      <td>檢查 <code>_hasCalledClosed</code>[State 欄位]，避免閉合回呼重複造成 mission index 多次增加。</td>
      <td>手動觸發兩次閉合流程，確認 onClosed 只執行一次。</td>
      <td rowspan="3">【功能函數】(Action Performer)<br>Purpose: [回呼防重/切頁通知]<br>Action: 檢查閉合旗標；第一次呼叫時標記已執行；呼叫父層 onClosed，讓 FullMissionPage 在畫面被遮住時切換到下一關。</td>
    </tr>
    <tr>
      <td>[L-14]</td>
      <td>[狀態鎖定]</td>
      <td>將 <code>_hasCalledClosed</code>[State 欄位] 設為 true，記錄閉合回呼已完成。</td>
      <td>第一次執行後確認旗標為 true。</td>
    </tr>
    <tr>
      <td>[L-15]</td>
      <td>[父層通知]</td>
      <td>呼叫 <code>widget.onClosed</code>[來自建構子 callback]，交由父層切換底層頁面。</td>
      <td>提供 mock onClosed，確認閉合點執行一次。</td>
    </tr>
    <tr>
      <td>[L-16]</td>
      <td>[重入防護]</td>
      <td>檢查 <code>_hasCalledFinished</code>[State 欄位]，避免完成回呼重複移除 overlay。</td>
      <td>手動呼叫完成流程兩次，確認 onFinished 只執行一次。</td>
      <td rowspan="3">【功能函數】(Action Performer)<br>Purpose: [回呼防重/轉場完成通知]<br>Action: 檢查完成旗標；第一次呼叫時標記已執行；呼叫父層 onFinished，讓 FullMissionPage 清除 overlay 並解除互動鎖。</td>
    </tr>
    <tr>
      <td>[L-17]</td>
      <td>[狀態鎖定]</td>
      <td>將 <code>_hasCalledFinished</code>[State 欄位] 設為 true，記錄完成回呼已執行。</td>
      <td>第一次執行後確認旗標為 true。</td>
    </tr>
    <tr>
      <td>[L-18]</td>
      <td>[父層通知]</td>
      <td>呼叫 <code>widget.onFinished</code>[來自建構子 callback]，讓父層移除 BattleStartTransition。</td>
      <td>完整動畫後確認父層不再顯示 overlay。</td>
    </tr>
    <tr>
      <td>[L-19]</td>
      <td>[Overlay UI]</td>
      <td>回傳填滿父層的 overlay，使用 <code>AbsorbPointer</code>[Widget] 吸收動畫期間的互動；結構見 <a href="#battle-transition-widget-tree">Battle Transition Widget Tree</a>。</td>
      <td>轉場期間點擊螢幕，確認不觸發底層按鈕或二次 nextFunction。</td>
      <td rowspan="4">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>context: BuildContext</code>，提供 overlay 建構環境。<br>Process: 建立全版 animated overlay；取得動畫 progress；依 <code>widget.monsterType</code>[來自建構子] 查出精靈屬性主題；建立上下兩片 sliding panel。回傳 Widget 詳見 <a href="#battle-transition-widget-tree">Battle Transition Widget Tree</a>。</td>
    </tr>
    <tr>
      <td>[L-20]</td>
      <td>[動畫取值]</td>
      <td>從 <code>_curve.value</code>[State 欄位動畫] 取得 <code>progress</code>[區域變數]，作為面板位移的 0 到 1 進度。</td>
      <td>動畫初始、閉合、反向結束時分別確認 progress 約為 0、1、0。</td>
    </tr>
    <tr>
      <td>[L-21]</td>
      <td>[屬性配色]</td>
      <td>使用 <code>LevelStyle.battleThemeForType(widget.monsterType)</code>[來自建構子 monsterType 與 LevelStyle 方法] 取得 <code>monsterTheme</code>[區域變數]，讓精靈面板背景色對應火、水、金或預設屬性。</td>
      <td>monsterType 分別傳入 <code>火</code>、<code>水</code>、<code>金</code>、未知字串，確認上方面板背景色不同且未知值使用預設主題。</td>
    </tr>
    <tr>
      <td>[L-22]</td>
      <td>[UI 組合]</td>
      <td>建立上下兩片 <code>_SlidingBattlePanel</code>[私有 Widget]；上方使用 <code>monsterTheme.primary/secondary</code>[區域變數]，下方使用 <code>AppTheme.accentColor/primaryColor</code>[AppTheme 靜態設定]，且不包含箭頭 UI。</td>
      <td>傳入有效松鼠圖與不同屬性怪物，確認下方面板維持 app 暖色系，上方面板隨屬性變化，畫面沒有箭頭。</td>
    </tr>
    <tr>
      <td>[L-23]</td>
      <td>[螢幕尺寸取得]</td>
      <td>使用 <code>MediaQuery.sizeOf(context)</code>[BuildContext 取得] 得到 <code>size</code>[區域變數]，供位移距離依裝置尺寸計算。</td>
      <td>測試 320px 與 1024px 寬度，確認 panel 初始位置都在畫面外。</td>
      <td rowspan="5">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>context: BuildContext</code> 提供螢幕尺寸；<code>progress: double</code>[來自建構子] 控制滑動進度；<code>isTopPanel: bool</code>[來自建構子] 決定上下 panel；<code>imagePath: String</code>[來自建構子] 為圖片來源；<code>backgroundColors: List&lt;Color&gt;</code>[來自建構子] 為面板背景漸層。<br>Process: 依螢幕尺寸與 progress 計算位移；建立斜切 panel、背景圖與主圖片；不建立箭頭。回傳 Widget 詳見 <a href="#sliding-panel-widget-tree">Sliding Panel Widget Tree</a>。</td>
    </tr>
    <tr>
      <td>[L-24]</td>
      <td>[水平位移]</td>
      <td>以 <code>size.width</code>[區域變數] 計算 <code>travelX</code>[區域變數]，確保 panel 能從左右畫面外滑入。</td>
      <td>寬度極小時確認滑入前 panel 不殘留在畫面中。</td>
    </tr>
    <tr>
      <td>[L-25]</td>
      <td>[垂直位移]</td>
      <td>以 <code>size.height</code>[區域變數] 計算 <code>travelY</code>[區域變數]，讓滑入方向帶斜向動感。</td>
      <td>高度很小的裝置上確認閉合時沒有可見空隙。</td>
    </tr>
    <tr>
      <td>[L-26]</td>
      <td>[位移計算]</td>
      <td>依 <code>isTopPanel</code>[來自建構子] 與 <code>progress</code>[來自建構子] 計算 <code>offset</code>[區域變數]；progress 0 在畫面外，progress 1 到閉合位置。</td>
      <td>progress = 0、0.5、1 時檢查 offset 方向與距離。</td>
    </tr>
    <tr>
      <td>[L-27]</td>
      <td>[UI 建構]</td>
      <td>使用 Transform、ClipPath 與 Stack 建立滑動斜切 panel；背景漸層使用 <code>backgroundColors</code>[來自建構子]，內容只包含淡背景圖與主圖片，且上方面板主圖片會往上對齊以避開斜切線；結構見 <a href="#sliding-panel-widget-tree">Sliding Panel Widget Tree</a>。</td>
      <td>確認上方面板精靈圖不貼近斜切線、下方面板松鼠圖仍在預期位置，且沒有 Icon arrow 或 Transform.rotate 箭頭節點。</td>
    </tr>
    <tr>
      <td>[L-28]</td>
      <td>[資料清理]</td>
      <td>將 <code>imagePath</code>[來自建構子] trim 成 <code>trimmedPath</code>[區域變數]，避免前後空白導致圖片判斷錯誤。</td>
      <td>imagePath 前後含空白與換行，確認仍可載入圖片。</td>
      <td rowspan="4">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>imagePath: String</code>[來自建構子]，可為 asset 或 http/https。<br>Process: 清理路徑；判斷網路圖或資產圖；空值與載入失敗時回傳 fallback。回傳 Widget 詳見 <a href="#transition-image-widget-tree">Transition Image Widget Tree</a>。</td>
    </tr>
    <tr>
      <td>[L-29]</td>
      <td>[來源判斷]</td>
      <td>檢查 <code>trimmedPath</code>[區域變數] 是否以 http 或 https 開頭，得到 <code>isNetworkImage</code>[區域變數]。</td>
      <td>傳入 http、https、asset 三種路徑，確認分流正確。</td>
    </tr>
    <tr>
      <td>[L-30]</td>
      <td>[空值防護]</td>
      <td>若 <code>trimmedPath</code>[區域變數] 為空，直接回傳 fallback icon，避免建立無效 Image。</td>
      <td>imagePath 為空字串或只有空白，確認畫面仍有替代 icon。</td>
    </tr>
    <tr>
      <td>[L-31]</td>
      <td>[圖片載入]</td>
      <td>依 <code>isNetworkImage</code>[區域變數] 回傳 Image.network 或 Image.asset，並在 errorBuilder 中回傳 fallback icon。</td>
      <td>傳入 404 網路圖或不存在 asset，確認不崩潰。</td>
    </tr>
    <tr>
      <td>[L-32]</td>
      <td>[斜線起點]</td>
      <td>以 <code>size.height</code>[CustomClipper 參數] 計算 <code>diagonalStart</code>[區域變數]，作為左側斜線高度。</td>
      <td>高度 600 與 1200 時確認斜線位置按比例縮放。</td>
      <td rowspan="4">【回傳函數】(Data Transformer)<br>Input: <code>size: Size</code>，目前 clip 區域尺寸。<br>Process: 依高度計算斜線左右端點；按上/下面板回傳不同多邊形路徑。<br>Output: <code>Path</code>，ClipPath 使用的裁切範圍。</td>
    </tr>
    <tr>
      <td>[L-33]</td>
      <td>[斜線終點]</td>
      <td>以 <code>size.height</code>[CustomClipper 參數] 計算 <code>diagonalEnd</code>[區域變數]，作為右側斜線高度。</td>
      <td>高度極小時確認 diagonalEnd 仍在可裁切範圍內。</td>
    </tr>
    <tr>
      <td>[L-34]</td>
      <td>[上方面板裁切]</td>
      <td>若 <code>isTopPanel</code>[來自建構子] 為 true，回傳覆蓋上半部且底邊為斜線的 Path。</td>
      <td>isTopPanel = true 時確認只顯示上方面板。</td>
    </tr>
    <tr>
      <td>[L-35]</td>
      <td>[下方面板裁切]</td>
      <td>若 <code>isTopPanel</code>[來自建構子] 為 false，回傳覆蓋下半部且頂邊為斜線的 Path。</td>
      <td>isTopPanel = false 時確認只顯示下方面板。</td>
    </tr>
    <tr>
      <td>[L-36]</td>
      <td>[重裁切判斷]</td>
      <td>比對 <code>oldClipper.isTopPanel</code>[舊裁切器參數] 與 <code>isTopPanel</code>[來自建構子]，只有上下 panel 身分改變時才重新裁切。</td>
      <td>同一 panel 連續 rebuild 時確認 shouldReclip 為 false。</td>
      <td>【回傳函數】(Data Transformer)<br>Input: <code>oldClipper: _BattlePanelClipper</code>，前一次裁切器。<br>Process: 比較上下 panel 身分是否變更。<br>Output: <code>bool</code>，是否需要重新裁切。</td>
    </tr>
  </tbody>
</table>

## 視覺化結構圖

### Battle Transition Widget Tree

[PositionedFill(全版定位容器)]  
└── [AbsorbPointer(吸收指標容器)]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [AnimatedBuilder(動畫建構器)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [Stack(堆疊容器)] // [L-22]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── [SlidingBattlePanel(精靈滑動面板)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [SlidingBattlePanel(松鼠滑動面板)]

### Sliding Panel Widget Tree

[Transform(位移容器)]  
└── [ClipPath(裁切容器)]  
&nbsp;&nbsp;&nbsp;&nbsp;└── [DecoratedBox(面板背景)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [Stack(堆疊容器)] // [L-27]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── [TransitionImage(背景圖片)]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── [TransitionImage(主圖片)]

### Transition Image Widget Tree

[ImageSourceBranch(圖片來源分流)]  
├── [ImageNetwork(網路圖片)] // [L-31]  
├── [ImageAsset(資產圖片)] // [L-31]  
└── [Icon(替代圖示)] // [L-30]

## 場景時序圖

情境 A [完整戰鬥開始轉場]：FullMissionPage 顯示 BattleStartTransition -> [L-01] -> [L-02] -> [L-03] -> [L-05] -> [L-06] -> [L-07] -> [L-13] -> [L-14] -> [L-15] -> [L-08] -> [L-09] -> [L-10] -> [L-11] -> [L-12] -> [L-16] -> [L-17] -> [L-18] 結束。

情境 B [精靈屬性配色]：BattleStartTransition build -> [L-19] -> [L-20] -> [L-21] -> 若 monsterType 為火/水/金使用對應 BattleLevelTheme，未知屬性使用預設主題 -> [L-22] 建立精靈面板結束。

情境 C [松鼠 App 風格配色]：BattleStartTransition build -> [L-22] -> 下方面板使用 AppTheme.accentColor 與 AppTheme.primaryColor -> [L-23] -> [L-27] 建立松鼠面板結束。

情境 D [圖片來源分流]：Sliding panel 建構圖片 -> [L-28] -> [L-29] -> 若空字串走 [L-30]；若 http/https 走 [L-31] Image.network；否則走 [L-31] Image.asset 結束。

情境 E [面板裁切]：Sliding panel 建立 ClipPath -> [L-32] -> [L-33] -> 上方面板走 [L-34]；下方面板走 [L-35] -> rebuild 時 [L-36] 決定是否重裁切結束。
