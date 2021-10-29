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
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchProgress: UIProgressView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    var filteredData: [BCGSVideo] = []
    var filteredItems: CuratedList!
    var dataManager = BCGSDataManager.sharedInstance
    var searchText: String = ""
    var lastOrientation: UIDeviceOrientation!
    var operationQueue = OperationQueue()
    var timer: Timer!
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        
        let metrics: [UIBarMetrics] = [
            .default,
            .compact,
            .defaultPrompt,
            .compactPrompt
        ]
        
        for metric in metrics {
            searchController.searchBar.setBackgroundImage(UIImage.imageWithColor(Style.Color.umcBlue),
                                                          for: .any,
                                                          barMetrics: metric)
        }
        
        searchController.searchBar.backgroundImage = UIImage.imageWithColor(Style.Color.umcBlue)
        searchController.searchBar.scopeBarBackgroundImage = UIImage.imageWithColor(Style.Color.umcBlue)
        searchController.searchBar.tintColor = UIColor.lightGray
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.textColor = UIColor.white
        }
        
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
        
        self.searchLabel.text = "SEARCH_PROMPT".localized(ConfigController.sharedInstance.stringsFilename)
        self.emptyResultsView.isHidden = true

        self.navigationItem.titleView = label
        
        self.operationQueue.maxConcurrentOperationCount = 1
        self.searchProgress.isHidden = true
        self.setBarButtonItems(animated: true)

        searchController.searchBar.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
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
            self.collectionView?.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
            self.collectionView?.contentOffset = CGPoint(x: 0, y: -44)
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
    
    // MARK: - UISearchBarDelegate

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredData.removeAll()
        filteredItems = nil
        self.handleEmptyResults()
        self.collectionView.reloadData()
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController)
    {
        if searchController.isActive {
            self.searchText = self.searchController.searchBar.text ?? ""
            
            if self.searchText.count < 3 {
                self.emptyResultsView.isHidden = true
                self.searchLabel.isHidden = false
                self.searchLabel.text = "SEARCH_PROMPT".localized(ConfigController.sharedInstance.stringsFilename)
                filteredData.removeAll()
                filteredItems = nil
                collectionView.reloadData()
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
        let showEmptyResultsView = filteredData.count == 0
        emptyResultsView.isHidden = !showEmptyResultsView

        let formatString = "SEARCH_NOT_FOUND".localized(ConfigController.sharedInstance.stringsFilename)
        self.noResultsLabel.text = String.localizedStringWithFormat(formatString,
                                                           self.searchText)
        self.searchProgress.isHidden = true
        self.searchLabel.isHidden = true
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

        if let playlistName = video.playlist?.name {
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
            self.searchProgress.isHidden = false
            self.searchLabel.isHidden = false
            self.emptyResultsView.isHidden = true
            self.collectionView.isHidden = true
            self.searchLabel.text = "SEARCH_SEARCHING".localized(ConfigController.sharedInstance.stringsFilename)
            
            self.timer = self.searchProgress.setIndeterminate(true)
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            self.searchProgress.isHidden = true
            self.collectionView.isHidden = false
            
            _ = self.searchProgress.setIndeterminate(false, inTimer: self.timer)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems?.items[section].videos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let reuseId = MTTitledLessonCollectionViewCell.reuseIdentifier
        let cvCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId,
                                                        for: indexPath)
        
        guard let cell = cvCell as? MTTitledLessonCollectionViewCell else {
            fatalError("Expected an MTTitledLessonCollectionViewCell object.")
        }
        
        if let item = filteredItems?.items[indexPath.section].videos?[indexPath.row] as? BCGSVideo {
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
        let name = NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MTCourseViewController.productPurchased(_:)),
                                               name: name,
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
