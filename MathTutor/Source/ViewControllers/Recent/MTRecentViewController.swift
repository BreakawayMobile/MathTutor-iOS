//
//  MTRecentViewController.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BGSMobilePackage

class MTRecentViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var recents: [BCGSVideo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = "RECENT_TITLE".localized(ConfigController.sharedInstance.stringsFilename)
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

        collectionView.register(UINib(nibName: MTTitledLessonCollectionViewCell.nibName, bundle: nil),
                                forCellWithReuseIdentifier: MTTitledLessonCollectionViewCell.reuseIdentifier)
        
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.enableNotifications()
        
        MTUserManager.shared.recents { (videos) in
            self.recents = videos
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disableNotifications()
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
        return self.recents.count 
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseId = MTTitledLessonCollectionViewCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? MTTitledLessonCollectionViewCell else {
            fatalError("Expected an MTTitledLessonCollectionViewCell object.")
        }
        
        let item = recents[indexPath.row]
        cell.configure(with: item,
                       indexPath: indexPath,
                       parentCollection: self.collectionView,
                       parentViewController: self)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: MTTitledLessonCollectionViewCell.cellWidth(),
                      height: MTTitledLessonCollectionViewCell.cellHeight(UIDevice.isPad))
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
    
}
