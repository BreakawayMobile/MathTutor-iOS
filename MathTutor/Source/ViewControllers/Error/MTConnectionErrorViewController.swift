//
//  MTConnectionErrorViewController.swift
//  umc
//
//  Created by Joseph Radjavitch on 4/13/16.
//  Copyright © 2016 bcgs. All rights reserved.
//

import UIKit
import BMMobilePackage

class MTConnectionErrorViewController: UIViewController {
    
    var reachability: Reachability!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachability = Reachability()
        
        reachability?.whenReachable = { reachability in
            BGSMobilePackage.sharedInstance.sessionController().sync()
            reachability.stopNotifier()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Orientation
    
    override var shouldAutorotate: Bool {
        let orientation = UIApplication.shared.statusBarOrientation
        let idiom = UIDevice.current.userInterfaceIdiom
        
        if idiom == .phone {
            if orientation == .portrait ||
               orientation == .portraitUpsideDown ||
               orientation == .unknown {
                return false
            } else {
                return true
            }
        }
        
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .phone ? [UIInterfaceOrientationMask.portrait] : [UIInterfaceOrientationMask.all]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        reachability = nil
    }
}
