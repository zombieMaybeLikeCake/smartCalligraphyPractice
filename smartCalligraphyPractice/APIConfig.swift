//
//  APIConfig.swift
//  smartCalligraphyPractice
//
//  對外服務的連線設定，集中在這一個檔案，之後要換網址/換 key 只改這裡。
//
//  apiKey 是 smart-calligraphy-api 那個 repo 的 README 裡寫的「展示用、
//  會不定期輪替」的那組 key（見 .env.example），不是永久機密——會被輪替
//  是設計上刻意的，不是這裡寫死了不好。真的要長期維護，應該改成從
//  Keychain 或設定畫面讀，而不是編進原始碼，但這個 App 目前只有自己
//  裝在自己 iPad 上用，先求能動。

import Foundation

enum APIConfig {
    /// 透過 frp 對外的網址，見 zi2ziV2/smartCalligraphy_FastAPI_Docker_重構計畫.md
    /// 第 8 節。目前是明文 HTTP + IP，沒有網域也還沒上 HTTPS，這也是為什麼
    /// Info.plist 裡要另外加 ATS 例外，不然 iOS 會直接擋掉這個連線。
    /// 展示/build 前填實際值——這裡故意不寫死真實網址/Key。
    static let baseURL = URL(string: "http://your-frp-host.example:8080")!

    static let apiKey = ""
}
