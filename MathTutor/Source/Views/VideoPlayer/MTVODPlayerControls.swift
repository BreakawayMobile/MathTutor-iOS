//
//  MTVODPlayerControls.swift
//  MarathonNosey
//
//  Created by Joseph Radjavitch on 1/4/16.
//  Copyright © 2016 bcgs. All rights reserved.
//

// swiftlint:disable file_header sorted_imports type_body_length file_length

import BrightcovePlayerSDK
import MediaPlayer
import BMMobilePackage
import UIKit

public protocol BCGSPlaybackDelegate: class {
    func playerClosed()
}

class MTVODPlayerControls: BCCiOSControls,
                            BCGSMobilePlaybackConsumer,
                            BCOVPlaybackSessionConsumer,
                            UIPopoverControllerDelegate,
                            BCGSPopupTableViewDelegate,
                            BCOVPlaybackControllerDelegate {

    let kDefaultFadeTime: Int32 = 5
    let kDefaultSeekTime: Int32 = 10
    let sliderImage = "circle_white"
    
    @IBOutlet fileprivate weak var errorLabel: UILabel!
    @IBOutlet fileprivate weak var episodeView: UIView!
    @IBOutlet fileprivate weak var seriesNameLabel: UILabel!
    @IBOutlet fileprivate weak var episodeNameLabel: UILabel!
    @IBOutlet fileprivate weak var skipBackButton: UIButton!
    @IBOutlet fileprivate weak var previousVideoButton: UIButton!
    @IBOutlet fileprivate weak var nextVideoButton: UIButton!
    @IBOutlet fileprivate weak var gradientEdgeImageView: UIImageView!
    @IBOutlet fileprivate weak var progressSlider: UISlider!
    @IBOutlet fileprivate weak var captionButton: UIButton!
    @IBOutlet fileprivate weak var volumeView: MPVolumeView!
    @IBOutlet fileprivate weak var airPlayButton: MPVolumeView!
    @IBOutlet fileprivate weak var titleView: UIView!
    @IBOutlet fileprivate weak var backArrowImageView: UIImageView!
    @IBOutlet weak var playbackRateButton: UIButton!
    
    @IBOutlet fileprivate weak var nextWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var nextTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var previousWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var previousTrailingConstraint: NSLayoutConstraint!
    
    fileprivate var currentPlayer: AVPlayer!
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    fileprivate var subtitleTable: BCGSPopoverTableViewController!
    fileprivate var rateTable: BCGSPopoverTableViewController!
    fileprivate var adCuePoints: [AnyObject]!
    fileprivate var tapGesture: UITapGestureRecognizer!
    fileprivate var currentVideo: BCOVVideo!
    fileprivate var nextClickProcessing: Bool!
    fileprivate var languageMap: NSArray! = [
        [ "en": "English" ],
        [ "de": "Deutsch" ],
        [ "es": "Espa\u{00F1}ol" ],
        [ "fr": "Fran\u{00E7}ais" ],
        [ "it": "Italiano" ],
        [ "pt": "Portugu\u{00EA}s" ],
        [ "ru": "P\u{0443}\u{0441}\u{0441}\u{043a}\u{0438}\u{0439}" ],
        [ "sv": "Svenska" ]
    ]
    
    var lesson: BCGSVideo!
    var hasPrevious: Bool!
    var hasNext: Bool!
    var parentVC: UIViewController!
    weak var playbackDelegate: BCGSPlaybackDelegate?
    var captionLanguage: String!
    var defaultNextWidth: CGFloat!
    var nextTrailingWidth: CGFloat!
    var defaultPreviousWidth: CGFloat!
    var previousTrailingWidth: CGFloat!
    var lastProgressEvent: TimeInterval!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastProgressEvent = 0
        self.hasPrevious = false
        
        defaultNextWidth = nextWidthConstraint.constant
        nextTrailingWidth = nextTrailingConstraint.constant
        defaultPreviousWidth = previousWidthConstraint.constant
        previousTrailingWidth = previousTrailingConstraint.constant
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.controlsView.translatesAutoresizingMaskIntoConstraints = false
        self.episodeView.translatesAutoresizingMaskIntoConstraints = false
        self.tapView.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextClickProcessing = false
        self.captionButton.isHidden = true
        self.fadeTime = kDefaultFadeTime
        self.rewindTime = kDefaultSeekTime
        self.slider.isHidden = true
        self.progressSlider.setThumbImage(UIImage(named: sliderImage), for: UIControl.State())
        self.progressSlider.minimumTrackTintColor = UIColor(hexString: "7AD2F6")
        
        let podBundle = Bundle(for: BCCiOSControls.self)
        let playImage = UIImage(named: "play_btn", in: podBundle, compatibleWith: nil)
        let pauseImage = UIImage(named: "pause_btn", in: podBundle, compatibleWith: nil)
        self.playPauseButton?.setImage(playImage, for: UIControl.State())
        self.playPauseButton?.setImage(pauseImage, for: UIControl.State.selected)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(MTVODPlayerControls.backTapped(_:)))
        backArrowImageView.isUserInteractionEnabled = true
        backArrowImageView.addGestureRecognizer(tapGesture)
        
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                                mode: AVAudioSession.Mode.default)
            }
        } catch _ { }
        
        self.airPlayButton.showsVolumeSlider = false
        self.volumeView.showsVolumeSlider = true
        self.volumeView.showsRouteButton = false
        
        BGSMobilePackage.sharedInstance.playbackController().addPlaybackConsumer(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        previousWidthConstraint.constant = hasPrevious == true ? defaultPreviousWidth : 0
        previousTrailingConstraint.constant = hasPrevious == true ? previousTrailingWidth : 0
        nextWidthConstraint.constant = hasNext == true ? defaultNextWidth : 0
        nextTrailingConstraint.constant = hasNext == true ? nextTrailingWidth : 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.episodeNameLabel.text = lesson.name
        self.seriesNameLabel.text = ""
     }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
        
    // MARK: - BCGSMobilePlaybackConsumer
    
    func didReceivePlaybackEvent(_ playbackEvent: String!, with object: Any!) {
        if playbackEvent == kBCGSEventPlaybackFail {
            if let errorDictionary = object as? [String: AnyObject?] {
                if let error = errorDictionary["error"] as? NSError {
                    if let apiError = error.userInfo["kBCOVPlaybackServiceErrorKeyAPIErrors"] as? [[String: Any]] {
                        if let errorCode = apiError[0]["error_code"] as? String {
                            let errorMessage = errorCode == "VIDEO_NOT_FOUND"
                                ? "The video cannot be found."
                                : "The video cannot be played at this time."
                            self.hideActivityIndicator()
                            self.showErrorSlate(errorMessage)
                        }
//                    }
//                    else {
//                        let errorMessage = error.localizedDescription
//                        self.hideActivityIndicator()
//                        self.showErrorSlate(errorMessage)
//                    }
                    } else if let underlyingError = error.userInfo["NSUnderlyingError"] as? NSError {
                        let errorMessage = underlyingError.localizedDescription
                        self.hideActivityIndicator()
                        self.showErrorSlate(errorMessage)
                    }
                }
            }
        }
    }
    
    // MARK: - BCOVPlaybackSessionConsumer
    
    func didAdvance(to session: BCOVPlaybackSession) {
        self.currentVideo = session.video
        self.currentPlayer = session.player
      
        if !(captionLanguage ?? "").isEmpty {
            self.enableSubtitlesForCountryCode(captionLanguage, emitEvent: true)
        }

        // Show the subtitles button if this is a video asset
        if self.currentVideo.properties["text_tracks"] != nil {
            self.captionButton.isHidden = false
        } else if let customFields = self.currentVideo.properties["custom_fields"] as? [String: Any] {
            if let captions = customFields["captions"] as? String {
                if captions != "" {
                    self.captionButton.isHidden = false
                }
            }
        }
        
        let storage = BCGSDataManager.sharedInstance.dataStorage()
        PlayProgress.update(progress: 0,
                            for: String(lesson.videoID.int64Value),
                            storage: storage)
    }

    func playbackSession(_ session: BCOVPlaybackSession, didChangeDuration duration: TimeInterval) {
        if Float(duration) != self.segmentDuration {
            super.updateDuration(Float(duration))
            super.currentSliderSegmentOriginTime(0, segmentLength: Float(duration))
            
//            Content.updateDuration(content, duration: duration)
        }
    }
    
    func playbackSession(_ session: BCOVPlaybackSession, didProgressTo progress: TimeInterval) {
        if progress.isFinite {
            self.updateCurrentTime(Float(progress))
            
            if isPlaying {
                self.hideActivityIndicator()
            }

            if self.lesson == nil /*|| self.content.isTrailer()*/ {
                return
            }
            
            if self.shouldClear(progress: progress) {
                self.clear(progress: progress)
            }
            
            if self.shouldUpdate(progress: progress) {
                self.update(progress: progress)
            }
        }
    }
    
    func shouldUpdate(progress: TimeInterval) -> Bool {
        if let duration = Double(self.lesson.totalDuration) {
            return ((duration  / 1000.0) - progress > 5) &&
                    ((progress - self.lastProgressEvent > 5) || (progress < self.lastProgressEvent))
        }
        
        return false
    }
    
    func update(progress: TimeInterval) {
        let storage = BCGSDataManager.sharedInstance.dataStorage()
        PlayProgress.update(progress: progress,
                            for: String(lesson.videoID.int64Value),
                            storage: storage)
    }
    
    func store(progress: TimeInterval) {
        let storage = BCGSDataManager.sharedInstance.dataStorage()
        PlayProgress.update(progress: progress,
                            for: String(lesson.videoID.int64Value),
                            storage: storage)
    }
    
    func shouldClear(progress: TimeInterval) -> Bool {
        if let duration = Double(lesson.totalDuration) {
            return (duration  / 1000.0) - progress < 5
        }
        
        return true
    }
    
    func clear(progress: TimeInterval) {
        let storage = BCGSDataManager.sharedInstance.dataStorage()
        PlayProgress.update(progress: 0,
                            for: String(lesson.videoID.int64Value),
                            storage: storage)
    }

    func playbackSession(_ session: BCOVPlaybackSession,
                         didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {

        if lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventPlay {
            nextClickProcessing = false
            super.setPlaybackPlaying(true)
            self.showActivityIndicator()
        } else if lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventEnd {
            if let videoId = lesson?.videoID?.int64Value {
                let storage = BCGSDataManager.sharedInstance.dataStorage()
                PlayProgress.update(progress: 0,
                                    for: String(videoId),
                                    storage: storage)
            }
            
            super.setPlaybackPlaying(false)
            self.endPlayback()
        } else if lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventFail {
            if let videoId = lesson?.videoID?.int64Value {
                let storage = BCGSDataManager.sharedInstance.dataStorage()
                PlayProgress.update(progress: 0,
                                    for: String(videoId),
                                    storage: storage)
            }
            
            let errorMessage = "The video cannot be played at this time."
            self.showErrorSlate(errorMessage)
            self.hideActivityIndicator()
           
            super.setPlaybackPlaying(false)
            self.endPlayback()
        } else if lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventPause {
            super.setPlaybackPlaying(false)
        } else if lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventFailedToPlayToEndTime {
            if let videoId = lesson?.videoID?.int64Value {
                let storage = BCGSDataManager.sharedInstance.dataStorage()
                PlayProgress.update(progress: 0,
                                    for: String(videoId),
                                    storage: storage)
            }
            
            self.endPlayback()
        }
    }
    
    func endPlayback() {
        if let videoPlayerVC = parentVC as? MTVideoPlayerViewController {
            videoPlayerVC.endPlayback()
        }
    }
    
    // MARK: - BCGSPopupTableViewDelegate
    
    func didSelectOption(_ option: [AnyHashable: Any]!, forTable table: BCGSPopoverTableViewController!) {
        if table == self.subtitleTable {
            if let cc = option["value"] as? String {
                self.enableSubtitlesForCountryCode(cc, emitEvent: true)
            }
        } else if table == rateTable {
            if let rate = option["value"] as? String,
               let fRate = Float(rate),
               let title = option["label"] as? String {
                self.playbackRateButton.setTitle(title, for: .normal)
                self.currentPlayer.rate = fRate
            }
        }
        
        self.closePopup()
    }
    
    func isLocaleEqual(_ locale: String, to countryCode: String) -> Bool {
        return locale.lowercased().hasPrefix(countryCode.lowercased())  
    }

    func enableSubtitlesForCountryCode(_ countryCode: String, emitEvent: Bool) {
        let group = AVMediaCharacteristic.legible
        let asset = self.currentPlayer?.currentItem?.asset
        if let selectionGroup = asset?.mediaSelectionGroup(forMediaCharacteristic: group) {
            var selectedTrack: AVMediaSelectionOption! = nil
    
            // Try to find the selected subtitle locale in the available tracks. If one
            // was not found, selectedTrack defaults to nil which will turn subtitles off.
            for track in selectionGroup.options {
                if let locale = track.locale {
                    if isLocaleEqual(countryCode, to: locale.identifier) {
                        selectedTrack = track
                        break
                    }
                }
            }
            
            self.currentPlayer?.currentItem?.select(selectedTrack, in: selectionGroup)
                
            if emitEvent {
                var eventDetails: [String: AnyObject] = [:]
                
                eventDetails["enabled"] = (selectedTrack != nil) as AnyObject
            
                // Add the non-translated version of the language name to the event details
                if selectedTrack != nil {
                    let metadata = AVMetadataItem.metadataItems(from: selectedTrack.commonMetadata,
                                                                withKey: "title",
                                                                keySpace: convertToOptionalAVMetadataKeySpace("comn"))
                    eventDetails["language"] = metadata[0].stringValue as AnyObject?
                }
            }
        }
    }

    // MARK: - Overrides
    
    override func updateCurrentTime(_ progress: Float) {
        super.updateCurrentTime(progress)
        
//        if(!self.progressSlider.isDragging) {
            self.progressSlider.value = progress / self.segmentDuration

    }

    // MARK: - Fade
    
    override func fadeIn() {
        super.fadeIn()
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.gradientEdgeImageView.alpha = 1.0
            self.episodeView.alpha = 1.0
        }) 
    }
    
    override func fadeOut() {        
        if (self.subtitleTable == nil && self.rateTable == nil && !self.slider.isDragging) {
            super.fadeOut()
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.gradientEdgeImageView.alpha = 0.0
                self.episodeView.alpha = 0.0
                self.closePopup()
            })
        }
    }
    
    // MARK: - UITapGestureRecognizer delegate
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    // MARK: - Tap Gesture
    
    @objc func backTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
//            if self.parentVC.parentViewController is UINavigationController {
//                let navController = self.parentVC.parentViewController as! UINavigationController
//                navController.popViewControllerAnimated(true)
//            }
//            else {
//                parentVC?.dismissViewControllerAnimated(true, completion: nil)
//            }
            
            self.playbackDelegate?.playerClosed()
            
            BGSMobilePackage.sharedInstance.playbackController().releasePlaybackResources()
            parentVC = nil
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func captionsTapped(_ sender: UIButton) {
        if let asset = self.currentPlayer?.currentItem?.asset {
            asset.loadValuesAsynchronously(forKeys: ["tracks"], completionHandler: { () -> Void in
                
                if asset.statusOfValue(forKey: "tracks", error: nil) != .loaded {
                    print("Tried to open subtitles menu but tracks isn't available yet")
                    return
                }
                
                let group = AVMediaCharacteristic.legible
                guard let selectionGroup = asset.mediaSelectionGroup(forMediaCharacteristic: group) else {
                    print("Failed to get media selection group")
                    return
                }
                
                var subtitlesOptions: [[String: String]] = self.load(subtitles: selectionGroup.options)
                
                subtitlesOptions.append(contentsOf: self.loadTextTracks(currentSubtitles: subtitlesOptions))
                
                var selectedIndex = 0
                let item = self.currentPlayer?.currentItem
                let contentSize = CGSize(width: 280, height: subtitlesOptions.count * 50)
                if let selectedOption = item?.currentMediaSelection.selectedMediaOption(in: selectionGroup) {
                    selectedIndex = self.currentIndex(of: selectedOption, subtitles: subtitlesOptions)
                }
                
                self.subtitleTable = BCGSPopoverTableViewController(options: subtitlesOptions,
                                                                    selectedIndex: Int32(selectedIndex))
                self.subtitleTable.delegate = self
                self.subtitleTable.modalPresentationStyle = .popover
                self.subtitleTable.preferredContentSize = contentSize

                DispatchQueue.main.async(execute: { () -> Void in
                    if let popover = self.subtitleTable.popoverPresentationController {
                        popover.delegate = self.subtitleTable
                        popover.sourceView = self.captionButton
                        popover.sourceRect = CGRect(x: 0,
                                                    y: 0,
                                                    width: 280,
                                                    height: subtitlesOptions.count * 50)
                    }
                    
                    self.parentVC?.present(self.subtitleTable,
                                           animated: true,
                                           completion: nil)
                })
            })
        }
    }
    
    @IBAction func playbackRateButtonPressed(_ sender: UIButton) {
        let playbackOptions: [[String: String]] = [
            ["label": "0.5x", "value": "0.5"],
            ["label": "0.8x", "value": "0.8"],
            ["label": "0.9x", "value": "0.9"],
            ["label": "1.0x", "value": "1.0"],
            ["label": "1.2x", "value": "1.2"],
            ["label": "1.5x", "value": "1.5"],
            ["label": "1.8x", "value": "1.8"],
            ["label": "2.0x", "value": "2.0"]
        ]
        
        let contentSize = CGSize(width: 280, height: playbackOptions.count * 50)
        self.rateTable = BCGSPopoverTableViewController(options: playbackOptions,
                                                        selectedIndex: Int32(0))
        self.rateTable.delegate = self
        self.rateTable.modalPresentationStyle = .popover
        self.rateTable.preferredContentSize = contentSize

        DispatchQueue.main.async(execute: { () -> Void in
            if let popover = self.rateTable.popoverPresentationController {
                popover.delegate = self.rateTable
                popover.sourceView = self.playbackRateButton
                popover.sourceRect = CGRect(x: 0,
                                            y: 0,
                                            width: 280,
                                            height: playbackOptions.count * 50)
            }
            
            self.parentVC?.present(self.rateTable,
                                   animated: true,
                                   completion: nil)
        })
    }
    
    func load(subtitles: [AVMediaSelectionOption]) -> [[String: String]] {
        var subtitlesArray: [[String: String]] = [ ["label": "Subtitles off", "value": "off"] ]

        for lang in self.languageMap {
            if let langMap = lang as? [String: String] {
                if let countryCode = (lang as AnyObject).allKeys[0] as? String {
                    // Find this track in the subtitle tracks from the AVPlayer
                    for track in subtitles {
                        if let locale = track.locale?.identifier {
                            if locale == countryCode {
                                if let title = langMap[countryCode] {
                                    subtitlesArray.append([ "label": title, "value": countryCode ])
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return subtitlesArray
    }
    
    func loadTextTracks(currentSubtitles: [[String: String]]) -> [[String: String]] {
        var textTracksArray: [[String: String]] = []
        
        if let textTracks = self.currentVideo.properties["text_tracks"] as? [[String: AnyObject]] {
            for trackItem in textTracks {
                if let title = trackItem["label"] as? String {
                    if let countryCode = trackItem["srclang"] as? String {
                        let subtitleObject: [String: String] = [ "label": title, "value": countryCode]
                        if !currentSubtitles.contains(where: { $0["value"] == subtitleObject["value"] }) {
                            textTracksArray.append(subtitleObject)
                        }
                    }
                }
            }
        }
        
        return textTracksArray
    }
    
    func currentIndex(of option: AVMediaSelectionOption, subtitles: [[String: String]]) -> Int {
        var selectedIndex = 0
        
        if let locale = option.locale?.identifier {
            for (index, value) in subtitles.enumerated() where value["value"] == locale {
                selectedIndex = index
                break
            }
        }
        
        return selectedIndex
    }
        
    @IBAction func skipBackTapped(_ sender: UIButton) {
        self.resetIdleTimer()

        var progress = self.progressSlider.value * self.segmentDuration
        progress -= Float(self.rewindTime)
        
        if progress < 0 {
            progress = 0
        }
        
        self.currentPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(progress), preferredTimescale: 1),
            toleranceBefore: CMTime.zero,
            toleranceAfter: CMTime.zero, completionHandler: { (_) -> Void in
                self.updateCurrentTime(Float(progress))
        }) 
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.resetIdleTimer()

        let progress = self.progressSlider.value * self.segmentDuration
        
        if progress.isFinite && progress > 0 && progress < self.segmentDuration {
            self.currentPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(progress), preferredTimescale: 1),
                                          toleranceBefore: CMTime.zero,
                                          toleranceAfter: CMTime.zero, completionHandler: { (_) -> Void in
                self.updateCurrentTime(Float(progress))
            })
        }
    }
    
    @IBAction func nextVideoTapped(_ sender: UIButton) {
        if nextClickProcessing == true {
            print("next click ignore")
            return
        }
        
        if self.currentPlayer == nil {
            print("next click ignore")
            return
        }
        
        self.nextClickProcessing = true
        self.showActivityIndicator()
        self.currentPlayer.pause()

        let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "nextVideo"), object: nil)
        }
    }
    
    @IBAction func previousVideoTapped(_ sender: UIButton) {
        if nextClickProcessing == true {
            print("next click ignore")
            return
        }
        
        if self.currentPlayer == nil {
            print("next click ignore")
            return
        }
        
        self.nextClickProcessing = true
        self.showActivityIndicator()
        self.currentPlayer.pause()
        
        let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "previousVideo"), object: nil)
        }
    }
    
    // MARK: - Subtitles
    
    func closePopup() {
        if self.subtitleTable != nil {
            self.subtitleTable.dismiss(animated: true, completion: nil)
            self.subtitleTable.delegate = nil
            self.subtitleTable = nil
        }
        
        if self.rateTable != nil {
            self.rateTable.dismiss(animated: true, completion: nil)
            self.rateTable.delegate = nil
            self.rateTable = nil
        }
    }

    // MARK: - deInit
    
    func releasePlaybackResources() {
        
        BGSMobilePackage.sharedInstance.playbackController().removePlaybackConsumer(self)

        self.lesson = nil
        self.playbackDelegate = nil
        self.parentVC = nil
        self.hasPrevious = nil
        self.hasNext = nil
        self.currentVideo = nil
        self.currentPlayer = nil
        
        if self.tapGesture != nil {
            backArrowImageView.removeGestureRecognizer(tapGesture)
            self.tapGesture = nil
        }
    }
    
    deinit {
        print("deinit")
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalAVMetadataKeySpace(_ input: String?) -> AVMetadataKeySpace? {
	guard let input = input else { return nil }
	return AVMetadataKeySpace(rawValue: input)
}
// swiftlint:enable file_header sorted_imports type_body_length file_length
