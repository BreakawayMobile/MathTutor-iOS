//
//  KeyboardManager.swift
//  Lightbox
//
//  Created by Matthew Daigle on 6/13/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class KeyboardManager: NSObject {

    // MARK: - Properties

    var activeView: UIView?
    private let scrollView: UIScrollView
    private let defaultContentInsets: UIEdgeInsets
    private let defaultContentOffset: CGPoint

    // MARK: - Lifecycle

    deinit {
        endObservingKeyboard()
    }

    init(with scrollView: UIScrollView) {
        self.scrollView = scrollView
        defaultContentInsets = scrollView.contentInset
        defaultContentOffset = scrollView.contentOffset

        super.init()

        beginObservingKeyboard()
    }

    // MARK: - Keyboard Management

    func beginObservingKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // swiftlint:disable notification_center_detachment
    func endObservingKeyboard() {
        NotificationCenter.default.removeObserver(self)
    }
    // swiftlint:enable notification_center_detachment

    @objc func keyboardWillShow(notification: Notification) {
        let keyboardInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        guard let keyboardRect = (keyboardInfo as? NSValue)?.cgRectValue else { return }
        guard let keyWindow = UIApplication.shared.keyWindow else { return }

        let scrollViewOriginInWindow = scrollView.convert(scrollView.frame.origin, to: keyWindow)
        let visibleViewHeight = (keyWindow.frame.height - keyboardRect.height)
        let keyboardOverlapHeight = scrollViewOriginInWindow.y + scrollView.frame.height - visibleViewHeight

        scrollView.isScrollEnabled = true
        let contentInsets = UIEdgeInsets(top: scrollView.contentInset.top,
                                         left: 0,
                                         bottom: keyboardOverlapHeight,
                                         right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        var visibleFrame = scrollView.frame
        visibleFrame.size.height -= keyboardOverlapHeight

        if let activeView = activeView, !visibleFrame.contains(activeView.frame.origin) {
            scrollView.scrollRectToVisible(activeView.frame, animated: true)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = defaultContentInsets
        scrollView.scrollIndicatorInsets = defaultContentInsets
        scrollView.contentOffset = defaultContentOffset
        scrollView.isScrollEnabled = false
    }
}
