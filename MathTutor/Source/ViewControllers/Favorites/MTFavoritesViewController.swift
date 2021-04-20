//
//  MTFavoritesViewController.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BMMobilePackage

class MTFavoritesViewController: UIViewController,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate,
                                 UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var recents: [BCGSVideo] = []
    var filteredItems: CuratedList!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = "FAVORITES_TITLE".localized(ConfigController.sharedInstance.stringsFilename)
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
        
        collectionView.register(UINib(nibName: MTSearchCollectionReusableView.nibName, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MTSearchCollectionReusableView.reuseIdentifier)

        collectionView.reloadData()
        beginObserving()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.enableNotifications()
        
        MTUserManager.shared.favorites { (videos) in
            self.recents = videos
            
            if self.filteredItems != nil {
                self.filteredItems = nil
            }
            self.filteredItems = CuratedList(self.recents)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disableNotifications()
    }
    
    // MARK: - Memory
    
    func beginObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(favoritesChanged),
                                               name: GlobalConstants.Notifications.userFavoriteChanged,
                                               object: nil)
    }
    
    // swiftlint:disable notification_center_detachment
    func endObserving() {
        NotificationCenter.default.removeObserver(self)
    }
    // swiftlint:enable notification_center_detachment
    
    @objc func favoritesChanged(notification: Notification) {
        MTUserManager.shared.favorites { (videos) in
            self.recents = videos
            
            if self.filteredItems != nil {
                self.filteredItems = nil
            }
            self.filteredItems = CuratedList(self.recents)
           
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
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
    
    // MARK: - Memory
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems?.items.count ?? 0   //1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredItems?.items[section].videos.count ?? 0  //recents.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseId = MTUntitledLessonCollectionViewCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? MTUntitledLessonCollectionViewCell else {
            fatalError("Expected an MTUntitledLessonCollectionViewCell object.")
        }
        
        if let item = filteredItems.items[indexPath.section].videos[indexPath.row] as? BCGSVideo {  //let item = recents[indexPath.row]
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
        
        if kind == UICollectionView.elementKindSectionHeader {
            let reuseId = MTSearchCollectionReusableView.reuseIdentifier
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseId, for: indexPath) as? MTSearchCollectionReusableView else {
                fatalError("Expected a MTSearchCollectionReusableView object.")
            }
            
            headerView.sizeToFit()
            
            //            let item = filteredData[indexPath.section]
            if let playlist = filteredItems?.items[indexPath.section] { //dataManager.playlist(for: item) {
                let playlistString = "> " + playlist.name
                
                let textRange = NSMakeRange(2, playlistString.characters.count - 2)
                let attributedText = NSMutableAttributedString(string: playlistString)
                attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
                
                // Add other attributes if needed
                headerView.courseLabel.attributedText = attributedText
                headerView.playlist = playlist
            }
            
            return headerView
        }
        
        return UICollectionReusableView()
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
        return CGSize(width: self.view.frame.size.width,
                      height: MTSearchCollectionReusableView.cellHeight)
    }

    // MARK: Notifications
    
    func enableNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MTCourseViewController.productPurchased(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification),
                                               object: nil)
        
    }
    
    // swiftlint:disable notification_center_detachment
    func disableNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    // swiftlint:enable notification_center_detachment
    
    func productPurchased(_ notification: Notification) {
        if let productIdentifier = notification.object as? String {
            if productIdentifier == MTProducts.MonthlySubscription {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Size Class
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    // MARK: - deinit
    
    deinit {
        endObserving()
    }
}
