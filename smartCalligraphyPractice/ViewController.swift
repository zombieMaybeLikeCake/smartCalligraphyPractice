//
//  ViewController.swift
//  smartCalligraphyPractice
//
//  Created by 羅琮棠 on 2023/10/23.
//
//  完全用程式碼佈局，沒有用 storyboard/XIB——跟 SceneDelegate 裡
//  `window.rootViewController = ViewController()` 這個既有寫法一致。
//
//  畫面：PKCanvasView 手寫畫布 + word/stroke 切換 + 送出/清除按鈕 +
//  結果圖片 + 狀態文字。送出時把畫布轉成 PNG，呼叫
//  CalligraphyAPIClient.predict(...)，拿到結果後把 base64 圖片解碼顯示。

import PencilKit
import UIKit

class ViewController: UIViewController {

    private let canvasView = PKCanvasView()
    private let taskControl = UISegmentedControl(items: ["整字 word", "單一筆劃 stroke"])
    private let submitButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    private let resultImageView = UIImageView()
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCanvas()
        setupControls()
        layoutViews()
    }

    // MARK: - Setup

    private func setupCanvas() {
        // 畫布背景一定要是不透明的白色：轉成 PNG 上傳時如果背景是透明的，
        // 後端 fitbest() 用灰階門檻值判斷筆劃（<100 算深色筆劃），透明區域
        // 轉灰階後顏色不一定是白色，會把整張畫布誤判成全部都是筆劃。
        canvasView.backgroundColor = .white
        canvasView.isOpaque = true
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 12)
        canvasView.drawingPolicy = .anyInput  // 手指也能寫，不強制一定要 Apple Pencil
        canvasView.layer.borderColor = UIColor.separator.cgColor
        canvasView.layer.borderWidth = 1
    }

    private func setupControls() {
        taskControl.selectedSegmentIndex = 0

        submitButton.setTitle("送出辨識", for: .normal)
        submitButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)

        clearButton.setTitle("清除畫布", for: .normal)
        clearButton.addTarget(self, action: #selector(didTapClear), for: .touchUpInside)

        resultImageView.contentMode = .scaleAspectFit
        resultImageView.backgroundColor = .secondarySystemBackground
        resultImageView.layer.borderColor = UIColor.separator.cgColor
        resultImageView.layer.borderWidth = 1

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center

        activityIndicator.hidesWhenStopped = true
    }

    private func layoutViews() {
        [canvasView, taskControl, submitButton, clearButton, resultImageView, statusLabel, activityIndicator]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            taskControl.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            taskControl.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            taskControl.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),

            canvasView.topAnchor.constraint(equalTo: taskControl.bottomAnchor, constant: 16),
            canvasView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            canvasView.widthAnchor.constraint(equalToConstant: 320),
            canvasView.heightAnchor.constraint(equalToConstant: 320),

            clearButton.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 12),
            clearButton.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),

            submitButton.centerYAnchor.constraint(equalTo: clearButton.centerYAnchor),
            submitButton.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),

            resultImageView.topAnchor.constraint(equalTo: taskControl.bottomAnchor, constant: 16),
            resultImageView.leadingAnchor.constraint(equalTo: canvasView.trailingAnchor, constant: 16),
            resultImageView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            resultImageView.heightAnchor.constraint(equalTo: canvasView.heightAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: resultImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: resultImageView.centerYAnchor),

            statusLabel.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: safe.bottomAnchor, constant: -16),
        ])
    }

    // MARK: - Actions

    @objc private func didTapClear() {
        canvasView.drawing = PKDrawing()
        resultImageView.image = nil
        statusLabel.text = nil
    }

    @objc private func didTapSubmit() {
        guard !canvasView.drawing.strokes.isEmpty else {
            statusLabel.text = "先在畫布上寫一個字，再按送出"
            return
        }

        let image = renderCanvasImage()
        let task: PredictTask = taskControl.selectedSegmentIndex == 0 ? .word : .stroke

        submitButton.isEnabled = false
        activityIndicator.startAnimating()
        statusLabel.text = "辨識中…"

        Task {
            do {
                let result = try await CalligraphyAPIClient.predict(task: task, image: image)
                await MainActor.run { self.handleSuccess(result) }
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                await MainActor.run { self.statusLabel.text = message }
            }
            await MainActor.run {
                self.submitButton.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
    }

    // MARK: - Helpers

    private func handleSuccess(_ result: PredictResult) {
        guard let data = Data(base64Encoded: result.imageBase64), let image = UIImage(data: data) else {
            statusLabel.text = "收到回應，但圖片解碼失敗"
            return
        }
        resultImageView.image = image
        statusLabel.text = String(
            format: "耗時 %.0f ms ‧ 位置 (%.0f, %.0f) ‧ 尺寸 %d×%d",
            result.inferenceMs, result.xPosition, result.yPosition, result.width, result.height
        )
    }

    /// 把畫布（含白色背景）攤平成一張 PNG。用 drawHierarchy 而不是
    /// canvasView.drawing.image(from:scale:)，因為後者只畫筆劃本身、
    /// 背景是透明的，會撞到跟 setupCanvas() 裡同一個「透明背景轉灰階
    /// 會被誤判成全部是筆劃」的問題。
    private func renderCanvasImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
        return renderer.image { _ in
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
    }
}
