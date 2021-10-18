//
//  MTWaitingViewController.swift
//  CommonFilmsTV
//
//  Created by Eric Hynds on 10/7/15.
//  Copyright © 2015 BCGS. All rights reserved.
//

import BMMobilePackage
import UIKit

open class MTWaitingViewController: UIViewController {
    @IBOutlet fileprivate weak var bootImage: UIImageView!
    @IBOutlet weak var waitingProgress: UIProgressView!
    
    lazy var configController = ConfigController.sharedInstance
    private var timer: Timer?
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.timer = waitingProgress.setIndeterminate(true)
    }
    
    public func setProgress(_ current: Int, max: Int) {
        if current > 0 {
            _ = self.waitingProgress.setIndeterminate(false, inTimer: self.timer)
            self.waitingProgress.progress = Float(current)/Float(max)
        }
    }
}
