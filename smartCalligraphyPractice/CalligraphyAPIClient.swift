//
//  CalligraphyAPIClient.swift
//  smartCalligraphyPractice
//
//  跟 smart-calligraphy-api 的 /predict/word、/predict/stroke 溝通。
//  純網路層，不碰任何 UIKit 畫面邏輯——這是刻意對齊後端 app/inference.py
//  「把模型怎麼跑和 HTTP 怎麼接分開」的同一個原則，這邊是「把畫布怎麼畫
//  和網路怎麼打分開」。
//
//  用原生 URLSession 手兜 multipart/form-data，沒有另外加 Alamofire 之類
//  的 SPM 套件——這台機器上沒有 Xcode，沒辦法實際驗證 Swift Package
//  Manager 能不能順利把套件解析、下載下來，用內建的東西風險最低。

import Foundation
import UIKit

enum PredictTask: String {
    case word
    case stroke

    var path: String { "/predict/\(rawValue)" }
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

enum APIClientError: LocalizedError {
    case invalidImage
    case unauthorized
    case rateLimited
    case server(status: Int, message: String)
    case decoding(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "圖片轉換失敗，畫布可能是空的"
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

    /// 送一張圖片去做風格轉換。label 是風格類別索引，對應後端
    /// embedding_num（目前是 40 類），預設 0。
    static func predict(task: PredictTask, image: UIImage, label: Int = 0) async throws -> PredictResult {
        guard let pngData = image.pngData() else {
            throw APIClientError.invalidImage
        }

        guard var components = URLComponents(
            url: APIConfig.baseURL.appendingPathComponent(task.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIClientError.network(URLError(.badURL))
        }
        components.queryItems = [URLQueryItem(name: "label", value: String(label))]

        guard let url = components.url else {
            throw APIClientError.network(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "X-API-Key")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = makeMultipartBody(pngData: pngData, boundary: boundary)

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
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                return try decoder.decode(PredictResult.self, from: data)
            } catch {
                throw APIClientError.decoding(error)
            }
        case 401:
            throw APIClientError.unauthorized
        case 429:
            throw APIClientError.rateLimited
        default:
            // FastAPI 的 HTTPException 回傳 {"detail": "..."}；422 這種自動
            // 驗證錯誤的 detail 是陣列不是字串，這裡解不出來就退回顯示原始文字。
            let message = (try? JSONDecoder().decode([String: String].self, from: data))?["detail"]
                ?? String(data: data, encoding: .utf8)
                ?? "未知錯誤"
            throw APIClientError.server(status: httpResponse.statusCode, message: message)
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
