//
//  UIViewController+Utils.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

extension UIViewController {

    typealias AlertDismissHandler = (() -> Void)

    func showAlert(title: String, message: String, dismissHandler: AlertDismissHandler? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { (_) -> Void in
            dismissHandler?()
        })
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    func dismissKeyboardOnTap() {
        // NOTE: canCancelContentTouches needs to be set to false for any UITableViews within the UIViewController.
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
