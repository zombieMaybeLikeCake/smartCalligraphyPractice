# smartCalligraphyPractice

書法練字 iOS App。練字格模式下顯示目標字，用手指/Apple Pencil 逐筆臨摹，**每畫完一筆**就即時把那一筆送到後端 [smart-calligraphy-api](../smart-calligraphy-api) 做風格轉換、疊回畫布上——不是整字一次送出。也可以打字直接生成練字格模板。畫面完全用程式碼佈局（沒有 storyboard）。

> 2026-09-09：這份是真正做過、功能完整的版本，取代了同一天稍早我在完全空白的 Xcode 範本上重寫的簡化版（PencilKit 單一畫布，只有 `/predict/stroke`）。那份沒有被刪，還在 git 歷史裡，但不再是主線——這個 repo 原本被我誤判成空專案，實際上完整版本一直放在旁邊 `smartCalligraphyPractice-orignal` 這個沒進 git 的資料夾裡，直到使用者指出來才發現。

## 現況

- `ViewController.swift`：練字格畫布（`drawWordForm`）、逐筆偵測（`touchesBegan/Moved/Ended`）、每畫完一筆呼叫 `/predict/stroke`
- `setViewController.swift`：設定畫面（齒輪按鈕開啟）——想練的字（打字生成練字格）、字體風格選單（22 種，對應後端 `label`）、練字框大小/格數、字帖模式開關、筆畫預測開關、顏色選擇器
- `CalligraphyAPIClient.swift`：純網路層，呼叫 `/predict/word`、`/predict/stroke`、`/synthesize/word`、`/synthesize/stroke`
- `APIConfig.swift`：API 網址、Key 集中設定的地方
- `LoadingViewController.swift` + `.xib`：等待指示器，目前程式碼裡是建好但沒有實際掛上去顯示（原本呼叫端都被註解掉了）
- `tabController.swift`、`setwordViewController.swift`：沒有被用到的舊嘗試，`SceneDelegate` 的 root view controller 是 `ViewController` 不是 `tabController`，這兩個檔案編譯得過但沒有任何東西會實際執行到

**已知限制**：
- **這幾個檔案在沒有 Mac／Xcode 的環境下用純文字編輯器改的，沒有實際 build 過**——語法逐行檢查過，但沒有編譯器把關，第一次在 Xcode 打開務必先 ⌘B build 一次，有錯誤很正常，不是你操作有問題。

**2026-09-09 更新：混合字體（blender）接上了**。一開始判斷「後端沒實作過」是只看了目前 `model/model.py` 沒有 `def blender()`；後來使用者指出更早的 `strokeStytleChangeServer.py`（沒有 V2 字尾那支）確實呼叫過 `model.blender(...)`，查證後發現方法本體真的遺失了，但底層的兩風格 embedding 內插能力還在 `UNetGenerator` 裡。`smart-calligraphy-api` 補了 `predict_blend()` 重建這個功能，`setViewController` 的混合比例滑桿現在選了真的有效果——見 `CalligraphyAPIClient.swift` 的 `StyleBlend`、`ViewController.swift` 的 `currentBlendLabel`/`currentBlendRatio`。

## 在 Xcode 打開

1. 用 Xcode 15 以上開 `smartCalligraphyPractice.xcodeproj`（專案是用 Xcode 14.3 建的，開啟時 Xcode 通常會自動把專案格式升級，跳出的提示都可以接受）
2. Xcode 左側選 target `smartCalligraphyPractice` → **Signing & Capabilities**，把 **Team** 換成你自己的 Apple ID（免費帳號也可以裝到自己的實機上，只是 App 7 天後要重新簽署一次）
3. `⌘B` build 一次，看有沒有語法錯誤

## 灌到 iPad 上

1. iPad 用傳輸線接電腦（或跟 Mac 同一個 Wi-Fi，用無線偵錯）
2. Xcode 上方的裝置選單選你的 iPad
3. `⌘R` 執行。**iPad 上第一次會安裝失敗**，因為系統還不信任你的開發者憑證：
   - iPad 上打開「設定」→「一般」→「VPN 與裝置管理」
   - 找到你的 Apple ID 底下的開發者 App，點「信任」
4. 再從 Xcode `⌘R` 一次，或直接在 iPad 上點 App 圖示

## 連線設定

`APIConfig.swift` 裡的網址跟 API Key 對應 `smart-calligraphy-api` README 的 Live Demo 那組——那組 key 是展示用、會不定期輪替，換了記得同步改這裡。`Info.plist` 裡加了一條只針對這個 IP 的 ATS 例外（App Transport Security），因為 API 目前是明文 HTTP、沒有網域也沒有 HTTPS；之後如果照 `smart-calligraphy-api` README 的技術選型說明接上 HTTPS，這條例外設定可以拿掉。

風格（label）、顏色（RGBA）現在是**每次請求**跟著 `/predict/*`、`/synthesize/*` 一起送——舊版是先用一個獨立的 GET 請求改伺服器端的全域狀態，這在新 API（無狀態）底下行不通，改成 `setViewController` 選好之後透過 `setvalue()` 傳回 `ViewController`，存在 `currentLabel`/`currentColor`，每次畫完一筆才用上。
