# novice_leading_page.dart 邏輯追蹤表

## 目前版本邏輯對照表

| ID | 邏輯描述 | 測資建議 |
| --- | --- | --- |
| [L-01] | 啟動新手教學流程，重設並啟用 `NoviceManager`。 | 呼叫前設 `currentStep = finished`、`isTutorialActive = false`，確認會回到 `notStarted` 並啟用教學。 |
| [L-02] | 標記 CoachMark 正在顯示，用於阻擋其他檢查流程重入。 | 連續呼叫 `showStep1`、`showStep5` 或 `_showTutorial`，確認 `_isShowingCoachMark = true` 時 `checkAndShow` 不會重複開啟。 |
| [L-03] | 建立第一段 CoachMark，綁定主角與頭像兩個目標。 | 只掛載其中一個 GlobalKey，確認建立流程仍保留兩個 target 設定。 |
| [L-04] | 僅在點擊頭像目標時推進到等待頭像頁，並結束目前 CoachMark。 | 傳入 `target.identify = "mainCharacter"`，確認不會改成 `waitingAvatarPage`。 |
| [L-05] | 檢查教學未啟動、CoachMark 顯示中、或已有檢查排程時直接返回。 | 分別設定 `isTutorialActive = false`、`_isShowingCoachMark = true`、`_isCheckScheduled = true`，確認不會排程 post-frame callback。 |
| [L-06] | 使用 `addPostFrameCallback` 等目前 frame 完成後再分派步驟，並以 `ensureVisualUpdate` 確保下一幀會執行；避免使用固定毫秒延遲。 | 在呼叫 `checkAndShow` 後先不 pump frame，確認尚未分派；再 pump 一個 frame，確認才執行 `_dispatchCurrentStep`。 |
| [L-07] | post-frame 後再次確認 `context.mounted`、教學仍啟動、且沒有 CoachMark 顯示中，避免使用失效 context 或重入。 | 在 callback 前 dispose widget，或把 `isTutorialActive = false`，確認 `_dispatchCurrentStep` 直接返回。 |
| [L-08] | 依 `NoviceManager.currentStep` 分派對應新手教學階段。 | 設定 `currentStep = notStarted`，確認不會觸發任何 step 顯示。 |
| [L-09] | 等待頭像頁時，必須同時找到頭像圖片與確認按鈕目標才顯示選頭像教學。 | 只掛載 `avatarImage` 或只掛載 `avatarCheak`，確認不會呼叫 `showStep2`。 |
| [L-10] | 若頭像選擇目標不存在，視為已跳過或已完成選擇，推進到任務階段並重新檢查。 | 兩個頭像選擇 key 都未掛載，確認 `currentStep` 改為 `avatarSelected`。 |
| [L-11] | 頭像已選擇後，啟動教學精靈對話與任務流程。 | 設定 `currentStep = avatarSelected` 並快速多次觸發，確認任務流程受 `_isStartingMission` 保護只啟動一次。 |
| [L-12] | 等待圖鑑按鈕時，按鈕目標存在才顯示圖鑑按鈕教學。 | 掛載 `encyclopediaButton`，確認呼叫 `showStep3`。 |
| [L-13] | 若圖鑑按鈕不存在但圖鑑卡片已存在，代表畫面已前進，改等卡片並重新檢查。 | 只掛載 `encyclopediaCard`，確認 `currentStep` 改為 `waitingEncyclopediaCard`。 |
| [L-14] | 等待圖鑑卡片時，卡片目標存在才顯示卡片教學。 | 掛載 `encyclopediaCard`，確認呼叫 `showStep4`。 |
| [L-15] | 若卡片不存在但文字區已存在，代表畫面已前進，改等文字並重新檢查。 | 只掛載 `encyclopediaText`，確認 `currentStep` 改為 `waitingEncyclopediaText`。 |
| [L-16] | 等待圖鑑文字時，文字目標存在才顯示最後一步教學。 | 設定 `encyclopediaText.currentContext = null`，確認不會呼叫 `showStep5`。 |
| [L-17] | 從頭像圖片與確認按鈕兩個 key 計算共同高亮區域。 | 兩個 RenderBox 距離極遠或尺寸差異大，確認共同框仍涵蓋兩者。 |
| [L-18] | 若共同高亮位置無法取得，重新委派檢查並提前返回。 | 讓其中一個 RenderObject 非 `RenderBox` 或 `hasSize = false`，確認不會直接建立 CoachMark。 |
| [L-19] | 最後一步中，點擊圖鑑文字目標才標記教學完成並結束 CoachMark。 | 傳入 `target.identify = "other"`，確認不會設為 `finished`。 |
| [L-20] | 最後一步允許點擊遮罩完成教學，但同樣限制目標是圖鑑文字。 | 點擊 overlay 時傳入非 `encyclopediaText` identify，確認不會完成教學。 |
| [L-21] | CoachMark 結束時，只有目前狀態為 `finished` 才顯示完成對話框。 | 手動把 step 設為 `waitingEncyclopediaText` 後觸發 finish，確認不顯示完成對話框。 |
| [L-22] | CoachMark finish callback 會清除顯示中旗標。 | CoachMark 正常 finish 後確認 `_isShowingCoachMark = false`。 |
| [L-23] | 使用 null-aware call 執行外部 finish callback，避免 callback 為 null 時拋錯。 | 建立 tutorial 時不傳 `onFinish`，確認 finish 不拋例外。 |
| [L-24] | 使用者按略過時清除顯示旗標、重設教學狀態，並回傳允許略過。 | 點擊 skip 後確認 `isTutorialActive = false` 且 callback 回傳 `true`。 |
| [L-25] | 共用顯示教學方法，建立 CoachMark 後立即顯示。 | 傳入單一 target，確認 `_buildTutorial(...).show(context)` 被執行。 |
| [L-26] | 任務流程啟動前檢查 `_isStartingMission`，防止任務重複開啟。 | 連續兩次呼叫 `_showTutorialFairyAndMission`，第二次應直接返回。 |
| [L-27] | 設定任務啟動旗標，直到任務流程結束或 context 失效才釋放。 | 對話框尚未關閉時再次觸發檢查，確認 `_isStartingMission` 仍為 true。 |
| [L-28] | 顯示不可點擊外部關閉的精靈發現對話框，並非同步等待使用者確認。 | 點擊 dialog 外部遮罩，確認不會 dismiss。 |
| [L-29] | 對話框關閉後檢查 `context.mounted`，若失效則釋放任務旗標並返回。 | 對話框關閉前 dispose 呼叫端 widget，確認不會 push 任務頁。 |
| [L-30] | 開啟教學任務頁並等待任務頁返回。 | 任務頁 push 後立即 pop，確認 await 可接續。 |
| [L-31] | 任務頁返回後釋放任務啟動旗標。 | 任務完成後確認 `_isStartingMission = false`，並可再次啟動任務流程。 |
| [L-32] | 任務返回後若 context 仍有效，重新檢查下一段教學。 | 任務頁返回前 dispose 原 context，確認不呼叫 `checkAndShow`。 |
| [L-33] | 透過 `Navigator.push` 開啟教學任務頁。 | 使用測試 Navigator 包住頁面，確認 route 可建立並進入 stack。 |
| [L-34] | 任務完成 callback 將教學階段推進到等待圖鑑按鈕。 | 觸發 `onMissionFinished` 後檢查 `currentStep = waitingEncyclopediaButton`。 |
| [L-35] | 任務完成時先檢查 `Navigator.canPop()`，只有可返回時才 pop，避免根路由 pop 例外。 | 模擬 `canPop() = false` 的根路由情境，確認不呼叫 pop。 |
| [L-36] | 顯示教學完成對話框，允許點擊外部關閉。 | 點擊完成 dialog 外部遮罩，確認 dialog 可 dismiss 且不自動導回主頁。 |
| [L-37] | 完成對話框按鈕會重設教學狀態。 | 按「回到主頁」後確認 `currentStep = notStarted`、`isTutorialActive = false`。 |
| [L-38] | 先關閉完成對話框本身。 | Dialog stack 中存在完成對話框時按按鈕，確認 dialog 被 pop。 |
| [L-39] | 導回遊戲主頁並清空既有路由堆疊。 | Navigator stack 有多層頁面，確認只剩 `GameMainPage` route。 |
| [L-40] | 目標位置尚不可用時進入重試入口。 | 讓 `_targetPositionFromKeys` 回傳 null，確認會進入 `_retryCheck`。 |
| [L-41] | 重試不使用固定時間延遲，而是重新委派給 `checkAndShow` 的 post-frame 排程與重入保護。 | 連續多次觸發 `_retryCheck`，確認 `_isCheckScheduled` 可避免排出多個 callback。 |
| [L-42] | 判斷單一 GlobalKey 是否已掛載到 widget tree。 | 設定 `key.currentContext = null`，確認回傳 false。 |
| [L-43] | 判斷多個 GlobalKey 是否全部掛載，任一缺失即 false。 | 傳入空 list、單一缺失 key、全部存在 key，確認 `every` 行為符合預期。 |
| [L-44] | 從 key 取得 RenderObject，並過濾成有尺寸的 RenderBox 清單；包含 null-safety 與型別防護。 | context 為 null、RenderObject 非 `RenderBox`、或 RenderBox `hasSize = false`。 |
| [L-45] | 若有效 RenderBox 數量與 key 數量不同，回傳 null 表示無法定位。 | 兩個 key 中只有一個有效 RenderBox，確認回傳 null。 |
| [L-46] | 走訪所有 RenderBox，計算共同外框的 left/top/right/bottom 邊界。 | RenderBox 有負座標、零寬高或極大尺寸，確認邊界計算仍正確。 |
| [L-47] | 用共同外框建立 `TargetPosition`，作為多目標高亮區域。 | 輸入兩個相距很遠的 RenderBox，確認 TargetPosition size 與 offset 正確。 |
| [L-48] | `NoviceManager.start()` 將步驟設為未開始並啟用教學。 | start 前任意 step 與 inactive 狀態，確認 start 後狀態固定。 |
| [L-49] | `NoviceManager.reset()` 將步驟設為未開始並停用教學。 | reset 前 `currentStep = finished`、`isTutorialActive = true`，確認 reset 後停用。 |
