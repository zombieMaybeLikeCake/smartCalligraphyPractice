//
//  LoadingViewController.swift
//  smartCalligraphyPractice
//
//  Created by 羅琮棠 on 2023/11/7.
//

import UIKit

class LoadingViewController: UIViewController {
    weak var delegate: DetailViewControllerDelegate?
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        // 添加黑色半透明背景视图
        view.addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // 添加等待指示器
        backgroundView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
    }
    @objc func hideDetailButtonTapped() {
           delegate?.hideDetailViewController()
       }
}
