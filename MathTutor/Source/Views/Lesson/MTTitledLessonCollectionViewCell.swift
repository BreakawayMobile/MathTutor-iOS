//
//  MTLessonCollectionViewCell.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/4/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BMMobilePackage

class MTTitledLessonCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MTTitledLessonCollectionViewCell"
    static let nibName = "MTTitledLessonCollectionViewCell"

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
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var titleViewHeightConstraint: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate var lesson: BCGSVideo!
    fileprivate var parentCV: UICollectionView!
    fileprivate var parentVC: UIViewController!
    fileprivate var docController: UIDocumentInteractionController!
    fileprivate var indexPath: IndexPath!
    fileprivate var labelTapGesture: UITapGestureRecognizer!
    fileprivate var titleFontSize: CGFloat!
    fileprivate var courseFontSize: CGFloat!
    fileprivate var lessonFontSize: CGFloat!
    
    static func cellHeight(_ extraHeight: Bool = false) -> CGFloat {
        var height: CGFloat = 175.0
        
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
        
        courseLabel.isUserInteractionEnabled = true
        
        let selector = #selector(MTTitledLessonCollectionViewCell.tapFunction(_:))
        self.labelTapGesture = UITapGestureRecognizer(target: self,
                                                      action: selector)
        
        courseLabel.addGestureRecognizer(labelTapGesture)
        
        let fontIncrement: CGFloat = UIDevice.isPad ? 2.0 : 0.0
        self.titleFontSize = titleLabel.font.pointSize + fontIncrement
        self.courseFontSize = courseLabel.font.pointSize + fontIncrement
        self.lessonFontSize = lessonLabel.font.pointSize + fontIncrement
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
        
        if let playlist = self.lesson.playlist {
            let playlistString = "> " + playlist.name
            
            let textRange = NSMakeRange(2, playlistString.count - 2)
            let attributedText = NSMutableAttributedString(string: playlistString)
            attributedText.addAttribute(NSAttributedString.Key.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: textRange)
            
            // Add other attributes if needed
            self.courseLabel.attributedText = attributedText
            
            if UIDevice.isPad {
                self.courseLabel.font = self.courseLabel.font.withSize(self.courseFontSize)
                self.titleLabel.font = self.titleLabel.font.withSize(titleFontSize)
            }
        }
    }
    
    func setCourseText() {
        let nameString: String = lesson.name
        let range = (nameString as NSString).range(of: " ")
        let boldRange = NSMakeRange(0, range.location)
        let labelString = NSMutableAttributedString(string: nameString)
        let boldFont = UIFont(name: Style.Font.Gotham.bold.rawValue,
                              size: self.lessonFontSize)
        let boldAttribute = [String.convertFromNSAttributedStringKey(NSAttributedString.Key.font): boldFont as Any]
        labelString.addAttributes(String.convertToNSAttributedStringKeyDictionary(boldAttribute), range: boldRange)
        
        let endRangeStart = range.length + 1
        let endRangeLength = nameString.length - endRangeStart
        let endRange = NSMakeRange(endRangeStart, endRangeLength)
        let regularFont = UIFont(name: Style.Font.Gotham.book.rawValue,
                                 size: self.lessonFontSize)
        let fontKey = String.convertFromNSAttributedStringKey(NSAttributedString.Key.font)
        let regularAttribute = [fontKey: regularFont as Any]
        labelString.addAttributes(String.convertToNSAttributedStringKeyDictionary(regularAttribute), range: endRange)
        
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
            let urlString = self.lesson.relatedDocument()
            guard let yourURL = URL(string: urlString) else {
                fatalError("Could ot get a valid url")
            }

            DispatchQueue.main.async {
                UIApplication.shared.open(yourURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        guard let shareLink = ConfigController.sharedInstance.share_url,
            let linkUrl = NSURL(string: shareLink as String) else {
                fatalError("Could not get a valid URL")
        }
        
        let maxMsgLength = 140 - shareLink.count
        let formatString = "SHARE_URL_LESSON".localized(ConfigController.sharedInstance.stringsFilename)
        let textToShare = String.localizedStringWithFormat(formatString,
                                                           lesson.name).truncateToLength(maxLength: maxMsgLength,
                                                                                         mode: .Middle,
                                                                                         addEllipsis: true)
        
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
                            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                                  let stringsFile = ConfigController.sharedInstance.stringsFilename else {
                                fatalError("Exected an AppDelegate object")
                            }
                            
                            let formatString = "MAX_FAVORITES".localized(stringsFile)
                            let favoriteCount = GlobalConstants.Maximum.favoriteCount
                            let localizedVersion = String.localizedStringWithFormat(formatString, favoriteCount)
                            
                            let alertController = UIAlertController(title: "",
                                                                    message: localizedVersion,
                                                                    preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK".localized(stringsFile),
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
    
    @objc func tapFunction(_ sender: UITapGestureRecognizer) {
        print("tap working")
        Controllers.push(with: String(self.lesson.playlist.playlistID.int64Value),
                         courseTitle: lesson.playlist.name)
    }

    // MARK: - deinit
    
    deinit {
        self.removeGestureRecognizer(labelTapGesture)
    }
}
