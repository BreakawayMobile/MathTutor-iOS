//
//  MTResumeViewController.swift
//  umc
//
//  Created by Joseph Radjavitch on 6/8/16.
//  Copyright © 2016 bcgs. All rights reserved.
//

// swiftlint:disable [ file_header sorted_imports ]

import BMMobilePackage
import UIKit

open class MTResumeViewController: UIViewController {

    let backImage = "back_arrow"
    
    @IBOutlet fileprivate weak var navBar: TallBar!
    @IBOutlet fileprivate weak var navItem: UINavigationItem!
//    @IBOutlet fileprivate weak var contentImageView: UIImageView!
    
    public typealias PlayActionCompletion = (PlayAction) -> Void
    
    public enum PlayAction {
        case restart
        case resume
        case cancel
    }
    
    lazy var imageUtils = BCGSImageUtilities.sharedInstance
    
    open var completion: PlayActionCompletion!

    var lesson: BCGSVideo! {
        didSet {
            if lesson != nil {
//                let placeholder = imageUtils.getImageWithColor(Style.Color.umcBlue,
//                                                               size: self.contentImageView.frame.size)
//                
//                if let url = URL(string: lesson.videoStillURL) {
//                    self.contentImageView?.sd_setImage(with: url,
//                                                       placeholderImage: placeholder)
//                }
            }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        navBar.barTintColor = UIColor.clear
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        
        let backButton = UIBarButtonItem(image: UIImage(named: backImage),
                                         style: .plain,
                                         target: self,
                                         action: #selector(MTResumeViewController.backTapped(_:)))
        navItem.leftBarButtonItem = backButton
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navBar.sizeToFit()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Orientation
    
//    override open var shouldAutorotate: Bool {
//        let orientation = UIApplication.shared.statusBarOrientation
//        let idiom = UIDevice.current.userInterfaceIdiom
//
//        if idiom == .phone {
//            if orientation == .landscapeLeft ||
//               orientation == .landscapeRight ||
//               orientation == .unknown {
//                return false
//            } else {
//                return true
//            }
//        }
//
//        return true
//    }
//
//    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return UIDevice.current.userInterfaceIdiom == .phone ? [UIInterfaceOrientationMask.landscape] : [UIInterfaceOrientationMask.all]
//    }
    open override var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone ? false : true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
//            return viewIsLoaded ? [UIInterfaceOrientationMask.landscape] : [UIInterfaceOrientationMask.all]
            return [UIInterfaceOrientationMask.landscape]
        }
        
        return [UIInterfaceOrientationMask.all]
    }

    // MARK: - IBAction

    @IBAction func restartButtonPressed(_ sender: UIButton) {
        self.completion?(.restart)
        self.completion = nil
        displayEnded()
    }
    
    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        self.completion?(.resume)
        self.completion = nil
        displayEnded()
    }
    
    @objc func backTapped(_ sender: UIBarButtonItem) {
        self.completion?(.cancel)
        self.completion = nil
        displayEnded()
    }
    
    func displayEnded() {
//        self.contentImageView?.sd_cancelCurrentImageLoad()
//        self.contentImageView.image = nil
    }
}
