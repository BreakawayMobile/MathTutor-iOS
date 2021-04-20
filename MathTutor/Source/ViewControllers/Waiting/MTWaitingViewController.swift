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
    @IBOutlet fileprivate weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var bootImage: UIImageView!
    
    lazy var configController = ConfigController.sharedInstance
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingSpinner.color = self.configController.loadingIndicatorColor
        self.loadingSpinner.startAnimating()
        
        //        let backgroundImageView = UIImageView(frame: self.view.frame)
        //        backgroundImageView.image = UIImage(named: configController.backgroundImage)
        //        self.view.layer.insertSublayer(backgroundImageView.layer, atIndex: 0)
        
//        if configController.bootImage != "" {
//            bootImage.image = UIImage(named: configController.bootImage)
//        }
//        
//        if configController.bootBackgroundColor != self.view.backgroundColor {
//            self.view.backgroundColor = configController.bootBackgroundColor
//        }
    }
}
