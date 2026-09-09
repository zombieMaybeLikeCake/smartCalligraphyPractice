//
//  CalligraphyAPIClient.swift
//  smartCalligraphyPractice
//
//  跟 smart-calligraphy-api 的 /predict/word、/predict/stroke、
//  /synthesize/word、/synthesize/stroke 溝通。純網路層，不碰任何 UIKit
//  畫面邏輯——對齊後端 app/inference.py「把模型怎麼跑和 HTTP 怎麼接分開」
//  的同一個原則。
//
//  用原生 URLSession 手兜 multipart/form-data，沒有另外加 Alamofire 之類
//  的 SPM 套件——這台機器上沒有 Xcode，沒辦法實際驗證 Swift Package
//  Manager 能不能順利把套件解析、下載下來，用內建的東西風險最低。

import Foundation
import UIKit

enum PredictTask: String {
    case word
    case stroke
}

/// 對應後端 app/schemas.py 的 StrokeResult。這個模型是風格轉換，不是
/// 分類器，所以欄位是位置/尺寸/圖片，不是 label/confidence。
struct PredictResult: Decodable {
    let xPosition: Double
    let yPosition: Double
    let width: Int
    let height: Int
    let imageBase64: String
    let inferenceMs: Double
}

/// 對應 /synthesize/* 的其中一個字，比 PredictResult 多一個 char 欄位
/// 標明是輸入文字裡的哪一個字。
struct SynthesizeCharResult: Decodable {
    let char: String
    let xPosition: Double
    let yPosition: Double
    let width: Int
    let height: Int
    let imageBase64: String
    let inferenceMs: Double
}

/// 畫筆顏色，對應後端 /predict/*、/synthesize/* 的 red/green/blue/alph
/// query 參數——舊版是先用一個獨立的 GET 請求（transmitcolor()）改伺服器
/// 端的全域顏色狀態，新版 API 無狀態，改成每次請求都帶著送。
struct StrokeColor {
    let red: Int
    let green: Int
    let blue: Int
    let alpha: Int

    static let black = StrokeColor(red: 0, green: 0, blue: 0, alpha: 255)
}

/// 混合字體：對應後端 /predict/*、/synthesize/* 的 label2／blend_ratio
/// 查詢參數（見 smart-calligraphy-api 的 app/inference.py predict_blend()）
/// ——兩個風格的 embedding 依 ratio 線性內插，ratio=0 純目前風格、ratio=1
/// 純 label2。舊版 setViewController.swift 的混合比率滑桿一直都在，只是
/// 之前後端沒有實作，這裡接上去而已，不是新加的 UI。
struct StyleBlend {
    let label2: Int
    let ratio: Float
}

enum APIClientError: LocalizedError {
    case invalidImage
    case invalidText
    case unauthorized
    case rateLimited
    case server(status: Int, message: String)
    case decoding(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "圖片轉換失敗，畫布可能是空的"
        case .invalidText:
            return "文字不能是空的"
        case .unauthorized:
            return "API Key 無效或未設定（X-API-Key）"
        case .rateLimited:
            return "打太快了，超過速率限制，稍後再試"
        case let .server(status, message):
            return "伺服器回傳錯誤 \(status)：\(message)"
        case .decoding:
            return "收到回應，但格式解析失敗"
        case let .network(error):
            return "網路連線失敗：\(error.localizedDescription)"
        }
    }
}

enum CalligraphyAPIClient {

    /// 送一張圖片（單一筆劃或整字）去做風格轉換。label 是風格類別索引，
    /// 對應後端 embedding_num（目前是 40 類），預設 0。
    static func predict(
        task: PredictTask,
        image: UIImage,
        label: Int = 0,
        color: StrokeColor = .black,
        blend: StyleBlend? = nil
    ) async throws -> PredictResult {
        guard let pngData = image.pngData() else {
            throw APIClientError.invalidImage
        }

        var queryItems = [
            URLQueryItem(name: "label", value: String(label)),
            URLQueryItem(name: "red", value: String(color.red)),
            URLQueryItem(name: "green", value: String(color.green)),
            URLQueryItem(name: "blue", value: String(color.blue)),
            URLQueryItem(name: "alph", value: String(color.alpha)),
        ]
        queryItems.append(contentsOf: blendQueryItems(blend))

        guard let url = makeURL(path: "/predict/\(task.rawValue)", queryItems: queryItems) else {
            throw APIClientError.network(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "X-API-Key")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = makeMultipartBody(pngData: pngData, boundary: boundary)

        let data = try await send(request)
        return try decode(PredictResult.self, from: data)
    }

    /// 打字生成：文字先用字型畫成圖，再送進模型，不用上傳圖片。逐字推論，
    /// 回傳陣列，順序對應輸入文字。對應後端 /synthesize/word、
    /// /synthesize/stroke。
    static func synthesize(
        task: PredictTask,
        text: String,
        label: Int = 0,
        color: StrokeColor = .black,
        blend: StyleBlend? = nil
    ) async throws -> [SynthesizeCharResult] {
        guard !text.isEmpty else {
            throw APIClientError.invalidText
        }

        var queryItems = [
            URLQueryItem(name: "text", value: text),
            URLQueryItem(name: "label", value: String(label)),
            URLQueryItem(name: "red", value: String(color.red)),
            URLQueryItem(name: "green", value: String(color.green)),
            URLQueryItem(name: "blue", value: String(color.blue)),
            URLQueryItem(name: "alph", value: String(color.alpha)),
        ]
        queryItems.append(contentsOf: blendQueryItems(blend))

        guard let url = makeURL(path: "/synthesize/\(task.rawValue)", queryItems: queryItems) else {
            throw APIClientError.network(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "X-API-Key")

        let data = try await send(request)
        return try decode([SynthesizeCharResult].self, from: data)
    }

    // MARK: - Shared helpers

    /// blend 是 nil 就回空陣列——不帶 label2 給後端，等同完全不混合，
    /// 跟現有的單一風格請求行為完全一樣（向後相容，見 main.py 的
    /// label2: Optional[int] = None）。
    private static func blendQueryItems(_ blend: StyleBlend?) -> [URLQueryItem] {
        guard let blend = blend else { return [] }
        return [
            URLQueryItem(name: "label2", value: String(blend.label2)),
            URLQueryItem(name: "blend_ratio", value: String(blend.ratio)),
        ]
    }

    private static func makeURL(path: String, queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(
            url: APIConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            return nil
        }
        components.queryItems = queryItems
        return components.url
    }

    private static func send(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIClientError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.network(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200:
            return data
        case 401:
            throw APIClientError.unauthorized
        case 429:
            throw APIClientError.rateLimited
        default:
            // FastAPI 的 HTTPException 回傳 {"detail": "..."}；422 這種自動
            // 驗證錯誤（例如 /synthesize/* 字數超過上限）的 detail 是陣列
            // 不是字串，兩種格式都試著解，都解不出來就退回顯示原始文字。
            let message = (try? JSONDecoder().decode([String: String].self, from: data))?["detail"]
                ?? String(data: data, encoding: .utf8)
                ?? "未知錯誤"
            throw APIClientError.server(status: httpResponse.statusCode, message: message)
        }
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIClientError.decoding(error)
        }
    }

    private static func makeMultipartBody(pngData: Data, boundary: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"sample.png\"\(lineBreak)"
                .data(using: .utf8)!
        )
        body.append("Content-Type: image/png\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(pngData)
        body.append(lineBreak.data(using: .utf8)!)
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)

        return body
    }
}
