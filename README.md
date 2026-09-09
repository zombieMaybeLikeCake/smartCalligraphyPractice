# smartCalligraphyPractice

用 Apple Pencil／手指在畫布上寫字，呼叫後端 [smart-calligraphy-api](../smart-calligraphy-api) 的 zi2zi 風格轉換模型，顯示生成結果。iOS App，畫面完全用程式碼佈局（沒有 storyboard）。

> 後端模型權重原本放在這個資料夾裡（`3000_net_D.pth`、`6000_net_D.pth`），2026-09-09 已經整組搬到獨立的 `smart-calligraphy-api` repo 部署成 FastAPI 服務；`word and stroke net path` 那組 Google Drive 連結目前只用來取得 stroke 模型的 checkpoint，跟這個 iOS App 本身無關，App 只透過 HTTP 打 API，不會在裝置上跑模型。

## 現況

- `ViewController.swift`：PKCanvasView 手寫畫布、`word`/`stroke` 切換、送出/清除、顯示結果圖片與延遲
- `CalligraphyAPIClient.swift`：純網路層，呼叫 `/predict/word`、`/predict/stroke`
- `APIConfig.swift`：API 網址、Key 集中設定的地方
- **這幾個檔案是在沒有 Mac／Xcode 的環境下用純文字編輯器寫的，沒有實際 build 過**——語法我逐行檢查過，但沒有編譯器把關，第一次在 Xcode 打開務必先 ⌘B build 一次，有錯誤很正常，不是你操作有問題。

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
