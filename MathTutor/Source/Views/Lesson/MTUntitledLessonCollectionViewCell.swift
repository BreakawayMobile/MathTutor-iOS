//
//  MTUntitledLessonCollectionViewCell.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/4/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BGSMobilePackage

class MTUntitledLessonCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MTUntitledLessonCollectionViewCell"
    static let nibName = "MTUntitledLessonCollectionViewCell"

    let configController = ConfigController.sharedInstance
    let dataManager = BCGSDataManager.sharedInstance
    
    @IBOutlet weak var lessonImageView: UIImageView!
    @IBOutlet weak var lessonLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var docButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var waitingBlurView: UIVisualEffectView!
    @IBOutlet weak var waitingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var playImageView: UIImageView!
    
    fileprivate var lesson: BCGSVideo!
    fileprivate var parentCV: UICollectionView!
    fileprivate var parentVC: UIViewController!
    fileprivate var docController: UIDocumentInteractionController!
    fileprivate var indexPath: IndexPath!
    fileprivate var titleFontSize: CGFloat!
    
    static func cellHeight(_ extraHeight: Bool = false) -> CGFloat {
        var height: CGFloat = 125.0
        
        if extraHeight == true {
            height *= 1.65
        }
        
        return height
    }
    
    static func cellWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        waitingBlurView.isHidden = true
        waitingSpinner.isHidden = true
        
        let fontIncrement: CGFloat = UIDevice.isPad ? 2.0 : 0.0
        self.titleFontSize = lessonLabel.font.pointSize + fontIncrement
    }
    
    func configure(with lesson: BCGSVideo,
                   indexPath: IndexPath,
                   parentCollection: UICollectionView,
                   parentViewController: UIViewController) {
        
        self.lesson = lesson
        self.indexPath = indexPath
        self.parentCV = parentCollection
        self.parentVC = parentViewController
        
        let placeholder = UIImage.imageWithColor(UIColor.flatGray())
        
        if let thumb = self.lesson.videoStillURL {
            if let url = URL(string: thumb) {
                lessonImageView.loadImageView(url, placeholderImage: placeholder)
            } else {
                lessonImageView.image = placeholder
            }
        } else {
            lessonImageView.image = placeholder
        }
        
        self.progressBar.setProgress(0, animated: false)
        
        let videoId = String(lesson.videoID.int64Value)
        let storage = BCGSDataManager.sharedInstance.dataStorage()
        PlayProgress.findProgress(videoId,
                                  storage: storage,
                                  completion: { (progress) in
                                    
            if let duration = progress?.currentPosition,
               let totalDuration = Double(self.lesson.totalDuration) {
                DispatchQueue.main.async {
                    let position = Float(duration) / Float(totalDuration / 1000.0)
                    self.progressBar.setProgress(position, animated: true)
                }
            }
        })
        
        Favorite.exists(favorite: videoId,
                    storage: storage,
                            completion: { (exists) in
                 
            let image = exists ? #imageLiteral(resourceName: "favorite_selected") : #imageLiteral(resourceName: "favorite")
            self.favoriteButton.setImage(image, for: .normal)
        })
        
        MTUser.current(storage: storage) { (user) in
            guard let user = user else {
                return
            }
            
            let subscribed = user.subscribed
            
            DispatchQueue.main.async {
                self.lockButton.isHidden = !(self.lesson.requiresSubscription() && !subscribed)
                
                if !self.lockButton.isHidden {
                    self.docButton.isHidden = true
                } else {
                    self.docButton.isHidden = self.lesson.relatedDocument() == ""
                }
                
                self.shareButton.isHidden = !self.lockButton.isHidden
                self.favoriteButton.isHidden = !self.lockButton.isHidden
                
                self.playImageView.image = self.lockButton.isHidden ? #imageLiteral(resourceName: "play") : #imageLiteral(resourceName: "video_lock")
                
                self.setCourseText()
            }
        }
    }
    
    func setCourseText() {
        let nameString: String = lesson.name
        let range = (nameString as NSString).range(of: " ")
        let boldRange = NSMakeRange(0, range.location)
        let labelString = NSMutableAttributedString(string: nameString)
        let boldFont = UIFont(name: Style.Font.Gotham.bold.rawValue,
                              size: self.titleFontSize)
        let boldAttribute = [NSFontAttributeName: boldFont as Any]
        labelString.addAttributes(boldAttribute, range: boldRange)
        
        let endRangeStart = range.length + 1
        let endRangeLength = nameString.length - endRangeStart
        let endRange = NSMakeRange(endRangeStart, endRangeLength)
        let regularFont = UIFont(name: Style.Font.Gotham.book.rawValue,
                                 size: self.titleFontSize)
        let regularAttribute = [NSFontAttributeName: regularFont as Any]
        labelString.addAttributes(regularAttribute, range: endRange)
        
        lessonLabel.attributedText = labelString
        
        if let duration = Double(lesson.totalDuration) {
            timeLabel.text = String.formatTime(duration)
        } else {
            timeLabel.text = ""
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func imageTapped(_ sender: UIButton) {
        Controllers.play(self.lesson)
    }
    
    @IBAction func lockTapped(_ sender: UIButton) {
        MTUserManager.shared.productPurchasePrompt()
    }
    
    @IBAction func docTapped(_ sender: UIButton) {
//        waitingBlurView.isHidden = false
//        waitingSpinner.isHidden = false

        DispatchQueue.global().async {
            //The URL to Save
            let urlString = self.lesson.relatedDocument()
            guard let yourURL = URL(string: urlString) else {
                fatalError("Could ot get a valid url")
            }

            UIApplication.shared.openURL(yourURL)
        }
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        guard let shareLink = ConfigController.sharedInstance.share_url,
            let linkUrl = NSURL(string: shareLink as String) else {
                fatalError("Could not get a valid URL")
        }
        
        let maxMsgLength = 140 - shareLink.characters.count
        let formatString = "SHARE_URL_LESSON".localized(ConfigController.sharedInstance.stringsFilename)
        let textToShare = String.localizedStringWithFormat(formatString,
                                                           lesson.name).truncateToLength(maxLength: maxMsgLength, mode: .Middle, addEllipsis: true)
        
        let controller = UIActivityViewController(activityItems: [textToShare, linkUrl], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {            
            if let popover = controller.popoverPresentationController {
                popover.sourceView = self.shareButton
            }
        }
        
        controller.view.tintColor = UIColor.red
        DispatchQueue.main.async {
            if self.parentVC.parent is UINavigationController {
                if let navController = self.parentVC.parent as? UINavigationController,
                   let visibleVC = navController.visibleViewController {
                    visibleVC.present(controller, animated: false, completion: nil)
                }
            } else {
                self.parentVC.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        MTUserManager.shared.favorites { (videos) in
            DispatchQueue.main.async {
                let videoId = String(self.lesson.videoID.int64Value)
                let storage = BCGSDataManager.sharedInstance.dataStorage()
                
                if let context = storage.mainContext {
                    if self.favoriteButton.imageView?.image != #imageLiteral(resourceName: "favorite_selected") {
                        if videos.count >= GlobalConstants.Maximum.favoriteCount {
                            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                fatalError("Exected an AppDelegate object")
                            }
                            
                            let formatString = "MAX_FAVORITES".localized(ConfigController.sharedInstance.stringsFilename)
                            let localizedVersion = String.localizedStringWithFormat(formatString, GlobalConstants.Maximum.favoriteCount)
                            
                            let alertController = UIAlertController(title: "",
                                                                    message: localizedVersion,
                                                                    preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK".localized(self.configController.stringsFilename),
                                                              style: .default,
                                                              handler: nil)
                            alertController.addAction(defaultAction)
                            
                            appDelegate.display(alert: alertController)
                            return
                        }
                        
                        Favorite.add(favorite: videoId,
                                     title: self.lesson.name,
                                     context: context,
                                     storage: storage,
                                     completion: { () in
                                        
                            if self.parentVC is MTFavoritesViewController {
                                self.parentCV.reloadData()
                            } else {
                                UIView.setAnimationsEnabled(false)
                                self.parentCV.reloadItems(at: [self.indexPath])
                                UIView.setAnimationsEnabled(true)
                            }
                        })
                    }
                    else {
                        Favorite.remove(favorite: videoId,
                                        context: context,
                                        storage: storage,
                                        completion: { () in
                                        
                            if self.parentVC is MTFavoritesViewController {
                                self.parentCV.reloadData()
                            } else {
                                UIView.setAnimationsEnabled(false)
                                self.parentCV.reloadItems(at: [self.indexPath])
                                UIView.setAnimationsEnabled(true)
                            }
                        })
                    }
                }
            }
        }
    }
    
    func tapFunction(_ sender: UITapGestureRecognizer) {
        print("tap working")
        Controllers.push(with: String(self.lesson.playlist.playlistID.int64Value),
                         courseTitle: lesson.playlist.name)
    }

    // MARK: - deinit
    
    deinit {
    }
}
