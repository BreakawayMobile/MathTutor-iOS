//
//  MTCourseViewController.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BMMobilePackage

class MTCourseViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    let dataManager = BCGSDataManager.sharedInstance
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingCoursesLabel: UILabel!
    @IBOutlet weak var waitProgress: UIProgressView!
    
    fileprivate var course: BCGSPlayList!
    fileprivate var courseID: String!
    fileprivate var courseTitle: String!
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = self.courseTitle ?? ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        
        if let font = UIFont(name: Style.Font.Gotham.book.rawValue, size: 16) {
            label.font = font
        }
        
        self.navigationItem.titleView = label
        
        self.setBarButtonItems(animated: true)
        
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(UINib(nibName: MTUntitledLessonCollectionViewCell.nibName, bundle: nil),
                                forCellWithReuseIdentifier: MTUntitledLessonCollectionViewCell.reuseIdentifier)
        
        collectionView.register(UINib(nibName: MTCourseCenteredCollectionHeaderView.nibName, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MTCourseCenteredCollectionHeaderView.reuseIdentifier)

        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.enableNotifications()

        guard let videoCount = self.course?.videos?.count, videoCount > 0 else {
            self.showSpinner()
            return
        }
        
        self.hideSpinner()
        collectionView?.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disableNotifications()
    }
    
    func config(with courseID: String, courseTitle: String) {
        self.courseTitle = courseTitle
        self.courseID = courseID
        self.course = self.dataManager.findPlaylistById((courseID as NSString))
        
        BGSMobilePackage.sharedInstance.playlist(forId: courseID) { _, _, _ in 
            
        }
    }
    
    // MARK: - UIBarButtonItem
    
    private func setBarButtonItems(animated: Bool) {
        let homeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Search"),
                                         style: .plain,
                                         target: self, action: #selector(searchButtonTapped))
        
        let rightBarButtonItems = [homeButton]
        
        self.navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: animated)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        Controllers.search()
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if let videoCount = course?.videos.count, videoCount > 0 {
            self.hideSpinner()
        }
        
        return course?.videos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseId = MTUntitledLessonCollectionViewCell.reuseIdentifier
        let cvCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId,
                                                        for: indexPath)
        
        guard let cell = cvCell as? MTUntitledLessonCollectionViewCell else {
            fatalError("Expected an MTUntitledLessonCollectionViewCell object.")
        }
        
        if let item = course.videos[indexPath.row] as? BCGSVideo {
            cell.configure(with: item,
                           indexPath: indexPath,
                           parentCollection: self.collectionView,
                           parentViewController: self)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reuseId = MTCourseCenteredCollectionHeaderView.reuseIdentifier
        let cvCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                     withReuseIdentifier: reuseId,
                                                                     for: indexPath)
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = cvCell as? MTCourseCenteredCollectionHeaderView else {
            return UICollectionReusableView()
        }
            
        headerView.courseLabel.text = self.course?.shortDescription ?? ""
        
        return headerView
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: MTUntitledLessonCollectionViewCell.cellWidth(),
                      height: MTUntitledLessonCollectionViewCell.cellHeight(UIDevice.isPad))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let descText = self.course?.shortDescription ?? ""
        let episodeText = (descText as NSString).replacingOccurrences(of: " ", with: "W")
        let options: NSStringDrawingOptions = [ .usesLineFragmentOrigin ]
        let fontKey = String.convertFromNSAttributedStringKey(NSAttributedString.Key.font)
        let font = UIFont(name: Style.Font.Gotham.book.rawValue, size: 17.0) ?? UIFont.systemFont(ofSize: 16.0)
        let attributes = String.convertToOptionalNSAttributedStringKeyDictionary([fontKey: font])
        let labelRect = episodeText.boundingRect(with: CGSize(width: collectionView.bounds.width - 20.0,
                                                              height: 9999.0),
                                                 options: options,
                                                 attributes: attributes,
                                                 context: nil)

        let size: CGSize = labelRect.size
        return CGSize(width: collectionView.bounds.width, height: ceil(size.height + 20))
    }
    
    // MARK: Notifications
    
    func enableNotifications() {
        let iapName = NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MTCourseViewController.productPurchased(_:)),
                                               name: iapName,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MTCourseViewController.dataRefresh(_:)),
                                               name: GlobalConstants.Notifications.backendDataRefresh,
                                               object: nil)
    }
    
    // MARK: - Spinner
    
    func showSpinner() {
        DispatchQueue.main.async {
            self.loadingCoursesLabel.isHidden = false
            self.waitProgress.isHidden = false
            self.collectionView.isHidden = true
            
            self.timer = self.waitProgress.setIndeterminate(true)
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            self.loadingCoursesLabel.isHidden = true
            self.waitProgress.isHidden = true
            self.collectionView.isHidden = false
            
            _ = self.waitProgress.setIndeterminate(false, inTimer: self.timer)
        }
    }
    
    // swiftlint:disable notification_center_detachment
    func disableNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    // swiftlint:enable notification_center_detachment
    
    @objc func productPurchased(_ notification: Notification) {
        if let productIdentifier = notification.object as? String {
            if productIdentifier == MTProducts.MonthlySubscription {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func dataRefresh(_ notification: Notification) {
        self.course = self.dataManager.findPlaylistById((courseID as NSString))
        collectionView.reloadData()
    }

    // MARK: - Size Class
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    // MARK: - deinit
    
    deinit {
        self.disableNotifications()
    }

}
