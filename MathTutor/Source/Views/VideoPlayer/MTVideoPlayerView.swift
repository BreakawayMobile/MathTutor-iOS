//
//  MTVideoPlayerView.swift
//  BCNH4MobileLibrary
//
//  Created by Joseph Radjavitch on 5/2/16.
//  Copyright © 2016 bcgs. All rights reserved.
//

import UIKit
import BrightcovePlayerSDK

// swiftlint:disable [ variable_name line_length ]

class MTVideoPlayerView: UIView {

    static let MT_VIDEO_ACCOUNT_ID: String = "61991422001"
    static let MT_VIDEO_POLICY_KEY: String = "BCpkADawqM3IHJ2eoVWggztYsIJiXJhevAgSWmH0c8xAzYdpOb9K5vgjbpO7tERtTWf69iLCskauOHlXPYy0o_h-CPBgORLV4nzdq0Bpg83ZLApEWLdRJJp45Uo"
    
    @IBOutlet fileprivate weak var videoViewContainer: UIView!
    
    lazy var sdkManager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.shared()
    
    var playbackController: BCOVPlaybackController!
    var sessionProvider: BCOVPlaybackSessionProvider!
    var playerView: BCOVPUIPlayerView!
    var sessionConsumer: BCOVPlaybackSessionConsumer! {
        didSet {
            if self.sessionConsumer != nil {
                self.playbackController.add(self.sessionConsumer)
            }
        }
    }
    
    static func defaultVideoPlayerView() -> MTVideoPlayerView {
        let bundle = Bundle(for: MTVideoPlayerView.self)
        guard let value = bundle.loadNibNamed("MTVideoPlayerView",
                                           owner: self,
                                           options: nil)?.first as? MTVideoPlayerView else {
            fatalError("Could not allocate a MTVideoPlayerView object")
        }
        
        return value
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    func setup() {
        
//        // Support for Fairplay - Begin
//        let proxy = BCOVFPSBrightcoveAuthProxy(applicationId: "", publisherId: "")
//        
//        proxy?.retrieveApplicationCertificate({ (applicationCertificate, error) in
//            self.playbackController = self.sdkManager.createFairPlayPlaybackControllerWithApplicationCertificate(applicationCertificate!,
//                                                                                                                 authorizationProxy: proxy!,
//                                                                                                                 viewStrategy: nil)
//        // Support for Fairplay - End
        
        self.playbackController = sdkManager.createPlaybackController()
        self.playerView = BCOVPUIPlayerView(playbackController: self.playbackController)
        self.playerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Do any additional setup after loading the view.
        self.videoViewContainer.addSubview(self.playerView)
        
        for attribute in [NSLayoutAttribute.top,
                          NSLayoutAttribute.bottom,
                          NSLayoutAttribute.leading,
                          NSLayoutAttribute.trailing] {
                
                let constraint = NSLayoutConstraint(item: self.playerView,
                                                    attribute: attribute,
                                                    relatedBy: .equal,
                                                    toItem: self.videoViewContainer,
                                                    attribute: attribute,
                                                    multiplier: 1,
                                                    constant: 0)
                
                self.videoViewContainer.addConstraint(constraint)
        }
//        // Support for Fairplay - Begin
//        })
//        // Support for Fairplay - End
        
        //self.playbackController = self.sdkManager
        
        self.sessionProvider = sdkManager.createSidecarSubtitlesSessionProvider(withUpstreamSessionProvider: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func videoView() -> UIView {
        return self.videoViewContainer
    }
    
    func playVideo(_ videoId: String, autoPlay: Bool) {
        let playbackService = BCOVPlaybackService(accountId: MTVideoPlayerView.MT_VIDEO_ACCOUNT_ID,
                                                  policyKey: MTVideoPlayerView.MT_VIDEO_POLICY_KEY)
        
        playbackService?.findVideo(withVideoID: videoId, parameters: nil) { (video, _, error) in
            if video != nil {
                self.playbackController.setVideos([video] as NSFastEnumeration!)
                
                if autoPlay {
                    self.playbackController.play()
                }
            } else {
                if let nsError = error as NSError? {
                    if let bcoveErrorArray = nsError.userInfo["kBCOVPlaybackServiceErrorKeyAPIErrors"] as? [[String: Any]] {
                        var errorCode = ""
                        if let value = bcoveErrorArray[0]["error_code"] as? String {
                            errorCode = value
                        }
                        let errorMessage = errorCode == "VIDEO_NOT_FOUND" ? "The video cannot be found." : "The video cannot be played at this time."
                        let alertView = UIAlertController(title: "", message: errorMessage, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            
                        })
                        alertView.addAction(defaultAction)
                        
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            fatalError("Exected an AppDelegate object")
                        }
                        
                        appDelegate.topViewController().present(alertView,
                                                                animated: true,
                                                                completion: nil)
                    }
                }
            }
        }
    }
    
    func pause() {
        self.playbackController.pause()
    }
    
    func resume() {
        self.playbackController.play()
    }
    
    func resumeVideoAtTime(_ playbackTime: CMTime, autoPlay: Bool) {
        self.playbackController.resumeVideo(at: playbackTime, withAutoPlay: autoPlay)
    }

    // MARK: - deinit
    
    func releasePlaybackResources() {
        if self.sessionConsumer != nil {
            self.playbackController.remove(self.sessionConsumer)
        }
    }
}
