//
//  LoadingView.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/26/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    // MARK: - IBOutlets

    @IBOutlet weak private var spinnerImageView: UIImageView!
    @IBOutlet weak private var messageLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        setText(to: "LOADING".localized)
        startSpin()
    }

    // MARK: - UI Configuration

    func setText(to text: String?) {
        messageLabel.text = text
    }

    // MARK: - Spinning

    private func startSpin() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = 2 * CGFloat.pi
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = Float.infinity

        spinnerImageView.layer.add(rotateAnimation, forKey: nil)
    }

    private func stopSpin() {
        spinnerImageView.layer.removeAllAnimations()
    }
}
