//
//  MTSearchViewController.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/8/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BMMobilePackage

class MTSearchViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UISearchControllerDelegate,
                              UISearchResultsUpdating,
                              UISearchBarDelegate,
                              UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBarContainerView: UIView!
    @IBOutlet var emptyResultsView: UIView!
    @IBOutlet weak var waitSpinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    
    var filteredData: [BCGSVideo] = []
    var filteredItems: CuratedList!
    var dataManager = BCGSDataManager.sharedInstance
    var searchText: String = ""
    var lastOrientation: UIDeviceOrientation!
    var operationQueue = OperationQueue()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.setBackgroundImage(UIImage.imageWithColor(Style.Color.umcBlue),
                                                      for: .topAttached,
                                                      barMetrics: .default)
        
        searchController.searchBar.backgroundImage = UIImage.imageWithColor(Style.Color.umcBlue)
        searchController.searchBar.scopeBarBackgroundImage = UIImage.imageWithColor(Style.Color.umcBlue)
        searchController.searchBar.tintColor = UIColor.lightGray
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.delegate = self
        
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = "SEARCH_TITLE".localized(ConfigController.sharedInstance.stringsFilename)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.textColor = UIColor.white
        
        if let font = UIFont(name: Style.Font.Gotham.bold.rawValue, size: 16) {
            label.font = font
        }
        
        self.navigationItem.titleView = label
        
        self.operationQueue.maxConcurrentOperationCount = 1
        self.waitSpinner.isHidden = true
        self.setBarButtonItems(animated: true)

        searchController.searchBar.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        searchBarContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.sizeToFit()
        
        definesPresentationContext = true
        
        collectionView.register(UINib(nibName: MTTitledLessonCollectionViewCell.nibName, bundle: nil),
                                forCellWithReuseIdentifier: MTTitledLessonCollectionViewCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.enableNotifications()
        
        collectionView?.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disableNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.searchController.searchBar.text = self.searchText
        
        UIView.animate(withDuration: 0.25, animations: {
            self.collectionView?.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            self.collectionView?.contentOffset = CGPoint(x: 0, y: -20)
        })
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.25, animations: {
            self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.collectionView?.contentOffset = CGPoint(x: 0, y: 0)
        })
    }
    
    // MARK: - UIBarButtonItem
    
    private func setBarButtonItems(animated: Bool) {
        let homeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "home"),
                                         style: .plain,
                                         target: self, action: #selector(homeButtonTapped))

        let rightBarButtonItems = [homeButton]
        
        self.navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: animated)
    }
    
    @IBAction func homeButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController)
    {
        if searchController.isActive {
            self.searchText = self.searchController.searchBar.text ?? ""
            
            if self.searchText.characters.count < 3 {
                filteredData.removeAll()
                filteredItems = nil
                return
            }
        } else {
            return
        }
        
        self.showSpinner()
        
        let currentText = self.searchText
        self.operationQueue.cancelAllOperations()
        self.operationQueue.addOperation {
            if currentText == self.searchText {
                self.filterData {
                    if currentText == self.searchText {
                        DispatchQueue.main.async {
                            if currentText == self.searchText {
                                self.hideSpinner()
                                self.handleEmptyResults()
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handleEmptyResults()
    {
        let showEmptyResultsView = /*searchController.isActive &&*/ filteredData.count == 0
        emptyResultsView.isHidden = !showEmptyResultsView
    }
    
    func filterData(completion: (() -> Void)!) {
        filteredData = dataManager.allVideos.filter({ (inVideo) -> Bool in
            return self.searchString(inVideo, searchTerm: self.searchText)
        })
        
        if filteredItems != nil {
            filteredItems = nil
        }
        filteredItems = CuratedList(self.filteredData)
        
        completion?()
    }
    
    func searchString(_ video: BCGSVideo, searchTerm: String) -> Bool {
        let terms = searchTerm.components(separatedBy: " ")
        let videoNameMatch = self.match(key: video.name, terms: terms, in: video)
        let videoDescriptionMatch = self.match(key: video.shortDescription, terms: terms, in: video)
        var contains = videoNameMatch || videoDescriptionMatch

        if let playlistName = video.playlist.name {
            contains = contains || self.match(key: playlistName, terms: terms, in: video)
        }
        
        return contains
    }
    
    func match(key: String, terms: [String], in video: BCGSVideo) -> Bool {
        var state = true
        
        terms.forEach { (term: String) in
            if key.lowercased().range(of: term.lowercased()) == nil {
                state = false
            }
        }
        
        return state
    }
    
    // MARK: - Spinner
    
    func showSpinner() {
        DispatchQueue.main.async {
            self.waitSpinner.isHidden = false
            self.emptyResultsView.isHidden = true
            self.collectionView.isHidden = true
            
            self.waitSpinner.startAnimating()
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            self.waitSpinner.isHidden = true
            self.collectionView.isHidden = false
            
            self.waitSpinner.stopAnimating()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems?.items.count ?? 0   //filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems?.items[section].videos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let reuseId = MTTitledLessonCollectionViewCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? MTTitledLessonCollectionViewCell else {
            fatalError("Expected an MTTitledLessonCollectionViewCell object.")
        }
        
        if let item = filteredItems?.items[indexPath.section].videos?[indexPath.row] as? BCGSVideo {//filteredData[indexPath.section]
            cell.configure(with: item,
                           indexPath: indexPath,
                           parentCollection: self.collectionView,
                           parentViewController: self)
        }
        
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: MTTitledLessonCollectionViewCell.cellWidth(),
                      height: MTTitledLessonCollectionViewCell.cellHeight(UIDevice.isPad))
    }
    
    // MARK: - Size Class
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
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
}
