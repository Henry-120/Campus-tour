# cryptography_level_page.dart 邏輯追蹤表

## 目前版本邏輯對照表

<table>
  <thead>
    <tr>
      <th>ID</th>
      <th>邏輯描述</th>
      <th>測資建議</th>
      <th>函數為單位</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>[L-01]</td>
      <td>目的[狀態初始化] 將 <code>_playerHp</code>[State 欄位] 初始化為 <code>CryptographyLevel.playerMaxHp</code>[靜態設定]，確保玩家每次進入頁面都有固定滿血起始值。</td>
      <td>設定 <code>playerMaxHp = 1</code> 或極大值，確認初始 HP 正確且不依賴前一次頁面狀態。</td>
      <td rowspan="2">【功能函數】(Action Performer)<br>Purpose: [狀態初始化]<br>Action: 初始化玩家血量，並用題目數與每題傷害計算敵方總血量。</td>
    </tr>
    <tr>
      <td>[L-02]</td>
      <td>目的[狀態初始化] 以 <code>widget.level.questionSet.length</code>[來自建構子 level] 乘上 <code>CryptographyLevel.enemyDamageOnCorrect</code>[靜態設定] 計算 <code>_enemyHp</code>[State 欄位]，讓敵方血量與題目數同步。</td>
      <td>傳入空題組或只有 1 題的 <code>level</code>，確認敵方血量分別為 0 或單題傷害值。</td>
    </tr>
    <tr>
      <td>[L-03]</td>
      <td>目的[主題選擇] 依 <code>widget.monsterModel.type</code>[來自建構子 monsterModel] 取得 <code>theme</code>[區域變數]，供戰鬥頁、卡片、HP 區塊共用視覺主題。</td>
      <td>傳入不同怪物 type 或未知 type，確認主題選擇不拋例外且 UI 可渲染。</td>
      <td rowspan="4">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>context: BuildContext</code>，提供 MediaQuery、Theme 與 widget tree 建構環境。<br>Process: 先取得怪物主題與目前題目的選項，再依可用高度計算怪物區高度，最後回傳<a href="#build-widget-tree">Build Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-04]</td>
      <td>目的[題目同步] 用 <code>_questionIndex</code>[State 欄位] 從 <code>widget.level.choiceSet</code>[來自建構子 level] 取出目前 <code>choices</code>[區域變數]。</td>
      <td>設定 <code>_questionIndex</code> 指向最後一題，確認選項仍可正確取得。</td>
    </tr>
    <tr>
      <td>[L-05]</td>
      <td>目的[UI 建構] 回傳加密關卡主要頁面，將怪物展示、題目卡與玩家血量面板組成可滾動內容；實際結構見 <a href="#build-widget-tree">Build Widget 結構圖</a>。</td>
      <td>使用低高度螢幕或長題目文字，確認頁面可滾動且不 overflow。</td>
    </tr>
    <tr>
      <td>[L-06]</td>
      <td>目的[版面邊界檢查] 由 <code>constraints.maxHeight</code>[LayoutBuilder 區域變數] 計算 <code>heroHeight</code>[區域變數]，限制怪物區高度介於 260 到 360 之間。</td>
      <td>將可用高度設為 100、620、2000，確認怪物區高度分別受下限、比例、上限控制。</td>
    </tr>
    <tr>
      <td>[L-07]</td>
      <td>目的[UI 建構] 依 <code>theme</code>[參數]、<code>height</code>[參數]、<code>_enemyHp</code>[State 欄位]、<code>widget.monsterModel.name</code>[來自建構子 monsterModel] 顯示怪物圖與敵方血條；結構見 <a href="#monster-hero-widget-tree">Monster Hero Widget 結構圖</a>。</td>
      <td>傳入很小寬度螢幕與長怪物名稱，確認 HP 區塊仍可顯示。</td>
      <td>【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>theme: BattleLevelTheme</code> 用於血條與前景樣式；<code>height: double</code> 用於怪物展示區高度。<br>Process: 建立怪物圖層、遮罩層與敵方 HP 區塊，回傳<a href="#monster-hero-widget-tree">Monster Hero Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-08]</td>
      <td>目的[UI 建構] 依 <code>theme</code>[參數] 與 <code>choices</code>[參數] 建立題目卡，包含目前題目、答案按鈕與回饋文字；結構見 <a href="#question-card-widget-tree">Question Card Widget 結構圖</a>。</td>
      <td>傳入 0 個、1 個、很多個選項，確認 List 生成與畫面排列符合預期。</td>
      <td rowspan="8">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>theme: BattleLevelTheme</code> 用於題目卡與按鈕樣式；<code>choices: List&lt;String&gt;</code> 為目前題目的選項。<br>Process: 顯示目前題目，逐一產生選項按鈕，依鎖定、選取、答對、答錯狀態決定互動與回饋；回傳<a href="#question-card-widget-tree">Question Card Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-09]</td>
      <td>目的[動態選項生成] 使用 <code>choices.length</code>[參數 choices] 產生每個答案按鈕。</td>
      <td>選項清單長度為 0，確認不會產生按鈕且頁面仍可渲染。</td>
    </tr>
    <tr>
      <td>[L-10]</td>
      <td>目的[選取狀態判斷] 比對 <code>_selectedChoiceIndex</code>[State 欄位] 與 <code>index</code>[List.generate 區域變數]，得出 <code>selected</code>[區域變數]。</td>
      <td>選取第一個與最後一個 index，確認只有對應按鈕標記為 selected。</td>
    </tr>
    <tr>
      <td>[L-11]</td>
      <td>目的[答案取得] 用 <code>_questionIndex</code>[State 欄位] 從 <code>widget.level.answerSet</code>[來自建構子 level] 取出 <code>correctAnswer</code>[區域變數]。</td>
      <td>答案文字包含空白或特殊符號，確認比對使用原字串。</td>
    </tr>
    <tr>
      <td>[L-12]</td>
      <td>目的[UI 反饋] 在 <code>_isAnswerLocked</code>[State 欄位] 為 true、目前按鈕被選取且文字等於 <code>correctAnswer</code>[區域變數] 時，將 <code>isCorrect</code>[區域變數] 設為 true。</td>
      <td>答案鎖定前選取正確答案，確認尚不顯示正確樣式。</td>
    </tr>
    <tr>
      <td>[L-13]</td>
      <td>目的[UI 反饋] 在答案鎖定、目前按鈕被選取且不是正確狀態時，將 <code>isWrong</code>[區域變數] 設為 true。</td>
      <td>選錯後確認只有被選的錯誤按鈕顯示錯誤樣式。</td>
    </tr>
    <tr>
      <td>[L-14]</td>
      <td>目的[重入防護] 若 <code>_isAnswerLocked</code>[State 欄位] 為 true 則停用按鈕，否則點擊時呼叫 <code>_submitAnswer(index)</code>，避免回饋期間重複送答。</td>
      <td>快速連點同一選項，確認只處理一次答案提交。</td>
    </tr>
    <tr>
      <td>[L-15]</td>
      <td>目的[UI 反饋] 僅當 <code>_feedbackText</code>[State 欄位] 不為 null 時顯示回饋文字，並用 <code>_isAnswerCorrect</code>[State 欄位] 決定成功或失敗樣式。</td>
      <td>答題前、答對、答錯三種狀態確認回饋區顯示與隱藏。</td>
    </tr>
    <tr>
      <td>[L-16]</td>
      <td>目的[UI 建構] 用 <code>_playerHp</code>[State 欄位] 與 <code>CryptographyLevel.playerMaxHp</code>[靜態設定] 建立玩家 HP 面板；結構見 <a href="#player-panel-widget-tree">Player Panel Widget 結構圖</a>。</td>
      <td>玩家 HP 為 0、半血、滿血時，確認面板文字與血條比例正確。</td>
      <td>【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>theme: BattleLevelTheme</code> 用於玩家血條樣式。<br>Process: 包裝共用 HP 區塊並固定 label 為 You，回傳<a href="#player-panel-widget-tree">Player Panel Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-17]</td>
      <td>目的[邊界檢查] 將 <code>currentHp</code>[參數] 夾在 0 到 <code>maxHp</code>[參數] 之間，得出 <code>clampedHp</code>[區域變數]，避免負值或超量血條。</td>
      <td><code>currentHp = -10</code>、<code>currentHp &gt; maxHp</code>，確認文字與比例不越界。</td>
      <td rowspan="5">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: <code>theme: BattleLevelTheme</code> 控制血條樣式；<code>currentHp: int</code> 為目前血量；<code>maxHp: int</code> 為最大血量；<code>label: String</code> 為顯示名稱；<code>invertTextColor: bool</code> 控制深色背景文字反白。<br>Process: 先限制血量邊界，再計算比例與文字樣式，最後回傳<a href="#hp-section-widget-tree">HP Section Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-18]</td>
      <td>目的[除零防護] 當 <code>maxHp</code>[參數] 為 0 時令 <code>ratio</code>[區域變數] 為 0.0，否則使用 <code>clampedHp / maxHp</code> 計算血條比例。</td>
      <td><code>maxHp = 0</code>，確認不發生除以零錯誤。</td>
    </tr>
    <tr>
      <td>[L-19]</td>
      <td>目的[文字可讀性] 依 <code>invertTextColor</code>[參數] 決定 <code>labelStyle</code>[區域變數] 是否覆寫為白色。</td>
      <td><code>invertTextColor = true</code>，確認敵方深色資訊框文字可讀。</td>
    </tr>
    <tr>
      <td>[L-20]</td>
      <td>目的[文字可讀性] 依 <code>invertTextColor</code>[參數] 決定 <code>valueStyle</code>[區域變數] 是否覆寫為白色。</td>
      <td><code>invertTextColor = false</code>，確認玩家面板保留主題文字樣式。</td>
    </tr>
    <tr>
      <td>[L-21]</td>
      <td>目的[UI 建構] 顯示 <code>label</code>[參數]、<code>clampedHp</code>[區域變數]、<code>maxHp</code>[參數] 與依 <code>ratio</code>[區域變數] 縮放的血條；結構見 <a href="#hp-section-widget-tree">HP Section Widget 結構圖</a>。</td>
      <td>label 為長字串且 HP 為極端值，確認文字與血條仍存在。</td>
    </tr>
    <tr>
      <td>[L-22]</td>
      <td>目的[資料清理] 從 <code>widget.monsterModel.imageUrl</code>[來自建構子 monsterModel] 去除前後空白，得出 <code>imagePath</code>[區域變數]。</td>
      <td>imageUrl 前後含空白或換行，確認仍可判斷路徑類型。</td>
      <td rowspan="4">【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: 無顯式參數，讀取 <code>widget.monsterModel.imageUrl</code>。<br>Process: 清理圖片路徑，判斷空字串、網路圖或資產圖，並為載入失敗提供 fallback；回傳<a href="#monster-image-widget-tree">Monster Image Widget 結構圖</a>或<a href="#image-fallback-widget-tree">Image Fallback Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-23]</td>
      <td>目的[來源判斷] 檢查 <code>imagePath</code>[區域變數] 是否以 http 或 https 開頭，得出 <code>isNetworkImage</code>[區域變數]。</td>
      <td>傳入 <code>http://</code>、<code>https://</code>、本機 asset、相對路徑，確認分流正確。</td>
    </tr>
    <tr>
      <td>[L-24]</td>
      <td>目的[空值防護] 若 <code>imagePath</code>[區域變數] 為空，直接回傳 fallback，避免建立無效 Image。</td>
      <td>imageUrl 為空字串或只有空白，確認顯示 fallback。</td>
    </tr>
    <tr>
      <td>[L-25]</td>
      <td>目的[圖片載入] 依 <code>isNetworkImage</code>[區域變數] 回傳網路圖片或資產圖片，並在 errorBuilder 中呼叫 <code>_buildImageFallback()</code> 處理載入失敗。</td>
      <td>傳入不存在的 asset 或 404 網路圖，確認 fallback 被顯示。</td>
    </tr>
    <tr>
      <td>[L-26]</td>
      <td>目的[異常替代 UI] 回傳圖片載入失敗或缺圖時的替代圖示；結構見 <a href="#image-fallback-widget-tree">Image Fallback Widget 結構圖</a>。</td>
      <td>強制圖片載入錯誤，確認 fallback 不依賴外部資源。</td>
      <td>【Build 函數 / Widget 返回函數】(UI Tree)<br>Input: 無。<br>Process: 建立缺圖替代容器與圖示，回傳<a href="#image-fallback-widget-tree">Image Fallback Widget 結構圖</a>。</td>
    </tr>
    <tr>
      <td>[L-27]</td>
      <td>目的[答案取得] 用 <code>index</code>[參數] 與 <code>_questionIndex</code>[State 欄位] 從 <code>widget.level.choiceSet</code>[來自建構子 level] 取出 <code>selectedChoice</code>[區域變數]。</td>
      <td><code>index</code> 為第一個與最後一個選項，確認取值正確。</td>
      <td rowspan="16">【功能函數】(Action Performer)<br>Purpose: [答題流程/狀態更新/非同步等待/導航回呼]<br>Action: 讀取選項與正解，鎖定答案並顯示回饋；答錯扣玩家 HP 並震動，答對扣敵方 HP；等待回饋時間後檢查 mounted；依玩家死亡、答錯重試、答對進題或完成關卡呼叫外部 callback。</td>
    </tr>
    <tr>
      <td>[L-28]</td>
      <td>目的[答案取得] 用 <code>_questionIndex</code>[State 欄位] 從 <code>widget.level.answerSet</code>[來自建構子 level] 取出 <code>correctAnswer</code>[區域變數]。</td>
      <td>題目與答案陣列長度不一致時，確認測試能捕捉 RangeError 風險。</td>
    </tr>
    <tr>
      <td>[L-29]</td>
      <td>目的[正誤判斷] 比對 <code>selectedChoice</code>[區域變數] 與 <code>correctAnswer</code>[區域變數]，得出 <code>isCorrect</code>[區域變數]。</td>
      <td>答案大小寫不同或包含前後空白，確認目前邏輯為精準字串比對。</td>
    </tr>
    <tr>
      <td>[L-30]</td>
      <td>目的[狀態更新] 透過 setState 更新 <code>_selectedChoiceIndex</code>、<code>_isAnswerLocked</code>、<code>_isAnswerCorrect</code>、<code>_feedbackText</code>[皆為 State 欄位]，立即反映送答結果。</td>
      <td>答題後立刻 pump，確認按鈕被鎖定且回饋文字出現。</td>
    </tr>
    <tr>
      <td>[L-31]</td>
      <td>目的[戰鬥計算] 答對時以 <code>math.max</code> 將 <code>_enemyHp</code>[State 欄位] 扣除 <code>CryptographyLevel.enemyDamageOnCorrect</code>[靜態設定]，最低保持 0。</td>
      <td>敵方剩餘 HP 小於單次傷害，確認扣血後不會變負值。</td>
    </tr>
    <tr>
      <td>[L-32]</td>
      <td>目的[戰鬥計算] 答錯時以 <code>math.max</code> 將 <code>_playerHp</code>[State 欄位] 扣除 <code>CryptographyLevel.playerDamageOnWrong</code>[靜態設定]，最低保持 0。</td>
      <td>玩家剩餘 HP 小於單次傷害，確認扣血後不會變負值。</td>
    </tr>
    <tr>
      <td>[L-33]</td>
      <td>目的[錯誤反饋] 若 <code>isCorrect</code>[區域變數] 為 false，非同步等待 <code>_shockController.wrongAnswerShock()</code>[State 欄位控制器] 觸發錯誤震動。</td>
      <td>答錯時 mock shock controller 或平台通道，確認會被呼叫一次。</td>
    </tr>
    <tr>
      <td>[L-34]</td>
      <td>目的[非同步等待] 等待 <code>CryptographyLevel.feedbackDuration</code>[靜態設定]，讓使用者看見答題回饋後再進入下一步。</td>
      <td>使用 fakeAsync 或 tester.pump 少於/等於回饋時間，確認狀態轉移時機。</td>
    </tr>
    <tr>
      <td>[L-35]</td>
      <td>目的[生命週期防護] 等待後檢查 <code>mounted</code>[State 生命週期屬性]，若頁面已卸載則提前返回，避免 setState 或 callback 操作失效 context。</td>
      <td>送答後在 delay 前 dispose widget，確認不再觸發後續 callback。</td>
    </tr>
    <tr>
      <td>[L-36]</td>
      <td>目的[失敗結算] 若答錯且 <code>_playerHp</code>[State 欄位] 已小於等於 0，呼叫 <code>widget.loseingFunction</code>[來自建構子 callback] 並結束流程。</td>
      <td>玩家 HP 剛好扣到 0，確認只觸發 loseingFunction，不重置題目。</td>
    </tr>
    <tr>
      <td>[L-37]</td>
      <td>目的[答錯重試] 若答錯但玩家仍有 HP，清除 <code>_selectedChoiceIndex</code>、<code>_isAnswerLocked</code>、<code>_feedbackText</code>[State 欄位]，允許同題重新作答。</td>
      <td>玩家剩 1 點以上答錯，等待後確認仍在同一題且按鈕恢復可點。</td>
    </tr>
    <tr>
      <td>[L-38]</td>
      <td>目的[進度回呼] 答對後呼叫 <code>widget.nextFunction</code>[來自建構子 callback]，通知外部答對一題。</td>
      <td>答對非最後一題，確認 nextFunction 被呼叫一次。</td>
    </tr>
    <tr>
      <td>[L-39]</td>
      <td>目的[完成判斷] 若 <code>_questionIndex</code>[State 欄位] 已在最後一題，或 <code>_enemyHp</code>[State 欄位] 小於等於 0，進入關卡完成流程。</td>
      <td>最後一題答對、非最後一題但敵方 HP 為 0，確認兩者都會完成。</td>
    </tr>
    <tr>
      <td>[L-40]</td>
      <td>目的[非同步等待] 完成時先將 <code>_feedbackText</code>[State 欄位] 設為完成訊息，再等待 500ms 讓完成回饋可見。</td>
      <td>最後一題答對後 pump 499ms 與 500ms，確認 finishFunction 時機。</td>
    </tr>
    <tr>
      <td>[L-41]</td>
      <td>目的[生命週期防護] 完成等待後再次檢查 <code>mounted</code>[State 生命週期屬性]，仍有效才呼叫 <code>widget.finishFunction</code>[來自建構子 callback]。</td>
      <td>完成等待期間 dispose widget，確認不呼叫 finishFunction。</td>
    </tr>
    <tr>
      <td>[L-42]</td>
      <td>目的[題目推進] 非最後一題答對後更新 <code>_questionIndex</code>[State 欄位] 並清除選取、鎖定、回饋狀態，進入下一題。</td>
      <td>多題關卡第一題答對，確認 index +1 且下一題按鈕可點。</td>
    </tr>
  </tbody>
</table>

## Widget 視覺化結構圖

### <a id="build-widget-tree"></a>Build Widget 結構圖

Scaffold  
└── Container // [L-05]  
&nbsp;&nbsp;&nbsp;&nbsp;└── SafeArea  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Padding  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Container  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── LayoutBuilder // [L-06]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── SingleChildScrollView  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── ConstrainedBox  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Column  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── Monster Hero // [L-07]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Padding  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Column  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── Question Card // [L-08]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Player Panel // [L-16]

### <a id="monster-hero-widget-tree"></a>Monster Hero Widget 結構圖

SizedBox  
└── Stack // [L-07]  
&nbsp;&nbsp;&nbsp;&nbsp;├── Monster Image // [L-25]  
&nbsp;&nbsp;&nbsp;&nbsp;├── DecoratedBox  
&nbsp;&nbsp;&nbsp;&nbsp;└── Positioned  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Align  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Container  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── HP Section // [L-21]

### <a id="question-card-widget-tree"></a>Question Card Widget 結構圖

Container  
└── Column // [L-08]  
&nbsp;&nbsp;&nbsp;&nbsp;├── Text // 目前題目  
&nbsp;&nbsp;&nbsp;&nbsp;├── 答案按鈕清單 // [L-09]  
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── Padding  
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── SizedBox  
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── ElevatedButton // [L-14]  
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Text // 選項文字  
&nbsp;&nbsp;&nbsp;&nbsp;└── Center // [L-15]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Text // 回饋文字

### <a id="player-panel-widget-tree"></a>Player Panel Widget 結構圖

Container // [L-16]  
└── HP Section // [L-21]

### <a id="hp-section-widget-tree"></a>HP Section Widget 結構圖

Column // [L-21]  
├── Row  
│&nbsp;&nbsp;&nbsp;&nbsp;├── Text // 名稱  
│&nbsp;&nbsp;&nbsp;&nbsp;└── Text // HP 數值  
└── ClipRRect  
&nbsp;&nbsp;&nbsp;&nbsp;└── SizedBox  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Stack  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── Container // 血條軌道  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── FractionallySizedBox // [L-18]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── Container // 血量填充

### <a id="monster-image-widget-tree"></a>Monster Image Widget 結構圖

Image.network 或 Image.asset // [L-25]  
└── errorBuilder  
&nbsp;&nbsp;&nbsp;&nbsp;└── Image Fallback // [L-26]

### <a id="image-fallback-widget-tree"></a>Image Fallback Widget 結構圖

Container // [L-26]  
└── Icon

## 場景時序圖

情境 A [進入加密關卡]：頁面建立 -> [L-01] -> [L-02] -> [L-03] -> [L-04] -> [L-06] -> [L-05] 結束

情境 B [顯示題目與互動狀態]：build 觸發 -> [L-08] -> [L-09] -> [L-10] -> [L-11] -> [L-12] -> [L-13] -> [L-14] -> [L-15] 結束

情境 C [顯示 HP 與怪物圖片]：build 觸發 -> [L-07] -> [L-22] -> [L-23] -> [L-24] 或 [L-25] -> [L-17] -> [L-18] -> [L-19] -> [L-20] -> [L-21] 結束

情境 D [答錯但仍可重試]：使用者點擊答案 -> [L-27] -> [L-28] -> [L-29] -> [L-30] -> [L-32] -> [L-33] -> [L-34] -> [L-35] -> [L-37] 結束

情境 E [答錯且玩家失敗]：使用者點擊答案 -> [L-27] -> [L-28] -> [L-29] -> [L-30] -> [L-32] -> [L-33] -> [L-34] -> [L-35] -> [L-36] 結束

情境 F [答對並進入下一題]：使用者點擊答案 -> [L-27] -> [L-28] -> [L-29] -> [L-30] -> [L-31] -> [L-34] -> [L-35] -> [L-38] -> [L-39] -> [L-42] 結束

情境 G [答對並完成關卡]：使用者點擊答案 -> [L-27] -> [L-28] -> [L-29] -> [L-30] -> [L-31] -> [L-34] -> [L-35] -> [L-38] -> [L-39] -> [L-40] -> [L-41] 結束
