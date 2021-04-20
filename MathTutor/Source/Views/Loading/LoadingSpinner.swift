//
//  LoadingSpinner.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/26/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class LoadingSpinner: NSObject {

    // MARK: - Shared Instance

    static let shared = LoadingSpinner()

    // MARK: - Properties

    private var loadingViewController: UIViewController!

    // MARK: - Initializers

    override init() {
        super.init()

        loadingViewController = UIViewController()
        loadingViewController.modalTransitionStyle = .crossDissolve
        loadingViewController.modalPresentationStyle = .overFullScreen
        let loadingView = LoadingView.fromNib()
        loadingView?.add(to: loadingViewController.view)
    }

    // MARK: - Show/Hide

    static func present() {
        Controllers.present(viewController: shared.loadingViewController)
    }

    static func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        shared.loadingViewController.dismiss(animated: animated, completion: completion)
    }
}
