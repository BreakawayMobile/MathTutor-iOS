//
//  MTVideoPlayerViewController.swift
//  BCNH4MobileLibrary
//
//  Created by Joseph Radjavitch on 4/26/16.
//  Copyright © 2016 bcgs. All rights reserved.
//

import AVFoundation
import AVKit
import BMMobilePackage
import UIKit

class MTVideoPlayerViewController: AVPlayerViewController, BCGSPlaybackDelegate {

    @IBOutlet fileprivate weak var videoView: UIView!

#if BASIC_CASE
    var videoPlayerView: MTVideoPlayerView!
#else
    lazy var playbackController: BCGSPlaybackController = BGSMobilePackage.sharedInstance.playbackController()

    var isPresented = false
    var playbackEnded = false
#endif
    
    var viewAdded: Bool!
    var playPosition: TimeInterval! = TimeInterval(0)
    var playerControls: MTVODPlayerControls!
    var lesson: BCGSVideo! {
        didSet {
            if lesson != nil {
                var playerConfig: [String: String] = [:]
                playerConfig["kBCGSPlayerType"] = "kBCGSPlayerTypeBCOV"
//                playerConfig["kBCGSPlayerControls"] = kBCGSPlayerControlsBCOV
                
                BGSMobilePackage.sharedInstance.setVODPlayerControls(with: playerConfig)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewAdded = false

#if BASIC_CASE
        if videoPlayerView == nil {
            videoPlayerView = MTVideoPlayerView.defaultVideoPlayerView()
            videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        }
#else
    
        NotificationCenter.default.setObserver(self,
                                               selector:#selector(MTVideoPlayerViewController.nextVideo(_:)),
                                               name:"nextVideo",
                                               object:nil)
    
        NotificationCenter.default.setObserver(self,
                                               selector:#selector(MTVideoPlayerViewController.previousVideo(_:)),
                                               name:"previousVideo",
                                               object:nil)
    
//        NotificationCenter.default.setObserver(self,
//                                               selector: #selector(MTVideoPlayerViewController.itemDidFinishPlaying(_:)),
//                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime.rawValue,
//                                               object: nil)
    
//        NotificationCenter.default.setObserver(self,
//                                               selector: #selector(MTVideoPlayerViewController.itemFailedPlaying(_:)),
//                                               name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime.rawValue,
//                                               object: nil)
    
#endif
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isPresented = true

        if viewAdded == false {
            self.viewAdded = true
            
#if BASIC_CASE
            self.videoView.insertSubview(videoPlayerView, atIndex:0)
            
            for attribute in [NSLayoutAttribute.Top,
                              NSLayoutAttribute.Bottom,
                              NSLayoutAttribute.Leading,
                              NSLayoutAttribute.Trailing] {
                                
                let constraint = NSLayoutConstraint(item: videoPlayerView,
                                                    attribute: attribute,
                                                    relatedBy: .Equal,
                                                    toItem: self.videoView,
                                                    attribute: attribute,
                                                    multiplier: 1,
                                                    constant: 0)
                
                self.videoView.addConstraint(constraint)
            }
    
            videoPlayerView.playVideo(lesson.videoID, autoPlay: true)
#endif
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIView.setAnimationsEnabled(true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // remove ourselves as a consumer for playback events. Safe to call even if we never added ourselves
        super.viewWillDisappear(animated)
        isPresented = false
        
        if self.isMovingFromParent || self.isBeingDismissed {
#if BASIC_CASE
            videoPlayerView.pause()
            videoPlayerView.releasePlaybackResources()
#else
            self.endPlayback()
#endif
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //
    //
    //
    
    // MARK: - Orientation
    
//    override var shouldAutorotate: Bool {
//        let orientation = UIApplication.shared.statusBarOrientation
//        let idiom = UIDevice.current.userInterfaceIdiom
//
//        if idiom == .phone {
//            if orientation == .landscapeRight ||
//               orientation == .landscapeLeft ||
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
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return UIDevice.current.userInterfaceIdiom == .phone ? [UIInterfaceOrientationMask.landscape] : [UIInterfaceOrientationMask.all]
//    }
    
    // MARK: - Orientation
    
    override var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone ? false : true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
//            return viewIsLoaded ? [UIInterfaceOrientationMask.landscape] : [UIInterfaceOrientationMask.all]
            return [UIInterfaceOrientationMask.landscape]
        }
        
        return [UIInterfaceOrientationMask.all]
    }

    // MARK: - Player Notifications
    
    func itemDidFinishPlaying(_ notification: Notification) {
        // Will be called when AVPlayer finishes playing playerItem
//        if content.nextEpisode() != nil {
//            self.playPosition = TimeInterval(0)
////            self.playVideo(content.nextEpisode())
//        } else {
            self.endPlayback()
//        }
    }
    
    func itemFailedPlaying(_ notification: Notification) {
        // Will be called when AVPlayer fails to finish playing playerItem
        self.endPlayback()
    }

#if !BASIC_CASE
    @objc func nextVideo(_ notification: Notification) {
        self.playPosition = TimeInterval(0)
//        self.playVideo(self.content.nextEpisode())
    }
    
    @objc func previousVideo(_ notification: Notification) {
        self.playPosition = TimeInterval(0)
//        self.playVideo(self.content.previousEpisode())
    }

    func playVideo(_ nextVideo: BCGSVideo!) {
//        if let videoId = nextVideo?.videoID {
            DispatchQueue.main.async {
                self.playbackController.releasePlaybackResources()
                self.lesson = nextVideo
                self.loadVideoViewWithPosition(self.playPosition)
                
//                if let content = UMCDataUtils.sharedInstance.getRealmObject().object(ofType: Content.self, forPrimaryKey: contentId as AnyObject) {
//                    self.content = content
//                    self.loadVideoViewWithPosition(self.playPosition)
//                }
            }
//        }
    }
    
    func loadVideoViewWithPosition(_ position: TimeInterval) {
        let idiom = UIDevice.current.userInterfaceIdiom
        let nibName = idiom == .phone ? "MTVODPlayerControls" : "MTVODPlayerControls_iPad"
        playerControls = MTVODPlayerControls(nibName: nibName, bundle: nil)
        playerControls.lesson = self.lesson
        playerControls.playbackDelegate = self
        playerControls.parentVC = self
        playerControls.hasPrevious = false  //content.previousEpisode() != nil
        playerControls.hasNext = false  //content.nextEpisode() != nil

        let videoString = String(self.lesson.videoID.int64Value)
        self.playbackController.playVideo(with: self,
                                          andControlsView: playerControls,
                                          withVideo: videoString,
                                          atTime: position)
    }

    // MARK: - BCGSPlaybackDelegate
    
    func playerClosed() {
        self.endPlayback()
    }
    
    func endPlayback() {
        if Thread.isMainThread == false {
            DispatchQueue.main.async(execute: {
                self.endPlayback()
            })
            
            return
        }
        
       if !playbackEnded {
            playbackEnded = true
        
//            NotificationCenter.default.removeObserver(self,
//                                                      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
//                                                      object: nil)
//        
//            NotificationCenter.default.removeObserver(self,
//                                                      name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
//                                                      object: nil)
        
            if playerControls != nil {
                playerControls.releasePlaybackResources()
                playerControls = nil
            }
        
            self.playbackController.pause()
            self.playbackController.releasePlaybackResources()
            self.isPresented = false
        
            if let parentVC = self.parent as? MTVideoViewController {
                parentVC.videoPlaybackCompleted()
            }
        
            ReviewManager.shared.videoView()
        }
    }
    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
#endif
    
    deinit {
#if BASIC_CASE
        if videoPlayerView != nil {
            videoPlayerView.releasePlaybackResources()
            videoPlayerView = nil
        }
#else
    NotificationCenter.default.removeObserver(self)
#endif
    }
}
