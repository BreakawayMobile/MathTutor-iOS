//
//  MTVideoViewController.swift
//  umc
//
//  Created by Joseph Radjavitch on 6/26/16.
//  Copyright © 2016 bcgs. All rights reserved.
//

import UIKit
import BMMobilePackage

class MTVideoViewController: UIViewController {

    @IBOutlet fileprivate weak var videoPlayerView: UIView!
    @IBOutlet fileprivate weak var resumeView: UIView!
//    @IBOutlet fileprivate weak var endscreenView: UIView!
    
    var lesson: BCGSVideo!
    var viewIsLoaded: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewIsLoaded = true
        
        let videoId = String(lesson.videoID.int64Value)
        let storage = BCGSDataManager.sharedInstance.dataStorage()
        PlayProgress.findProgress(videoId,
                                  storage: storage,
                                  completion: { (progress) in
                                    
            if let position = progress?.currentPosition, position > 0 {
                self.showResumeView(position)
            } else {
                self.showVideoPlayerView(TimeInterval(0))
            }
        })
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configure(with lesson: BCGSVideo) {
        self.lesson = lesson
    }
    
    func showResumeView(_ playProgress: TimeInterval) {
        self.resumeView.isHidden = false
        self.videoPlayerView.isHidden = true
//        self.endscreenView.alpha = 0
        
        if let resumeVC = viewControllerOfClass(MTResumeViewController.self) as? MTResumeViewController {
            resumeVC.lesson = lesson
            resumeVC.completion = { (playAction) in
                if playAction == .resume {
                    let playPosition = TimeInterval(playProgress)
                    self.showVideoPlayerView(playPosition)
                } else if playAction == .restart {
                    self.showVideoPlayerView(TimeInterval(0))
                } else if playAction == .cancel {
                    self.dismissVideoViews()
                }
                return
            }
        }
    }
    
    func showVideoPlayerView(_ playProgress: TimeInterval) {
        self.resumeView.isHidden = true
        self.videoPlayerView.isHidden = false
//        self.endscreenView.alpha = 0
        
        if let playerVC = viewControllerOfClass(MTVideoPlayerViewController.self) as? MTVideoPlayerViewController {
            playerVC.lesson = self.lesson
            playerVC.playPosition = playProgress
            playerVC.playVideo(self.lesson)
        }
    }
    
    func videoPlaybackCompleted() {
//        if !UMCAuthenticationStore.sharedInstance.hasCurrentUser() {
//            showEndscreenView()
//        } else {
            dismissVideoViews()
//        }
    }
    
//    func showEndscreenView() {
//        self.resumeView.alpha = 0
//        self.videoPlayerView.alpha = 0
//        self.endscreenView.alpha = 1
//    }
    
    func viewControllerOfClass(_ aClass: AnyClass) -> UIViewController! {
        for vc in self.children {
            if vc.isKind(of: aClass) {
                return vc
            }
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Orientation
    
    override var shouldAutorotate: Bool {
        return true // UIDevice.current.userInterfaceIdiom == .phone ? false : true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
//            return viewIsLoaded ? [UIInterfaceOrientationMask.landscape] : [UIInterfaceOrientationMask.all]
            return [UIInterfaceOrientationMask.landscape]
        }
        
        return [UIInterfaceOrientationMask.all]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func dismissVideoViews() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
        
        viewIsLoaded = false
        self.dismiss(animated: true, completion: nil)
    }
}
