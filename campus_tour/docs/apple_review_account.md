# Apple Review Account 操作手冊

審核帳號：`caijamie22+appreview@gmail.com`

密碼不得提交到 Git。本文件不記錄密碼；只在 Firebase Console 建立，並填入 App Store Connect 的 App Review Information。

## 建立帳號

1. Firebase Console > Authentication > Users > Add user。
2. Email 使用 `caijamie22+appreview@gmail.com`，設定專用密碼。
3. 不需要在 Console 尋找 Email verified 開關；下方的 `reviewer:grant` 腳本會透過 Admin SDK 將它設為已驗證。
4. 建立符合正式規則的 `users/{uid}` 文件，暱稱建議 `Apple Reviewer`。
5. 預先準備可操作的遊戲資料，但保留至少一隻精靈尚未捕捉。

## 授予 Reviewer Claim

腳本使用 Google Application Default Credentials，不需要也不可把 Service Account JSON 放進專案：

```bash
gcloud auth application-default login
gcloud config set project campus-tour-679e9
cd functions
npm ci
npm run reviewer:grant
```

帳號必須重新登入，新的 ID Token 才會包含 `appReviewer: true`。

撤銷權限：

```bash
cd functions
npm run reviewer:revoke
```

## 審核操作

1. 使用 Email 與密碼登入。
2. 開啟設定，使用 Apple Review Demo 的位置映射功能。
3. 回到地圖，選擇尚未捕捉的精靈。
4. 進入 NFC 畫面後，點選 `Apple Review: Simulate NFC Tag`。
5. 模擬 Tag 會走和實體 NFC 相同的 ID 比對成功 handler，再繼續任務與捕捉流程。

一般帳號沒有 Reviewer Claim，因此不會看到位置映射或 NFC 模擬按鈕。

## App Review Notes

```text
Campus Tour uses location and NFC as part of its core campus exploration and
character collection experience.

Review account:
Email: caijamie22+appreview@gmail.com
Password: 123456

Because App Review may take place outside National Central University and
without access to our physical NFC tags, this dedicated account has access to
a clearly labeled Apple Review Demo Mode.

Location flow:
1. Sign in with the review account.
2. Open Settings.
3. In the Apple Review Demo section, tap the location mapping button.
4. Return to the map and select an available character.

NFC flow:
1. Continue until the NFC screen appears.
2. Tap “Apple Review: Simulate NFC Tag”.
3. Complete the remaining mission and verify the captured character appears
   in the collection.

The demo controls are authorized by a server-issued Firebase custom claim and
are unavailable to regular accounts. The simulated NFC result enters the same
expected-tag success handler as a physical scan; it does not grant admin access.

Privacy Policy:
https://campus-tour-679e9.web.app/privacy.html

Support:
https://campus-tour-679e9.web.app/support.html
```
