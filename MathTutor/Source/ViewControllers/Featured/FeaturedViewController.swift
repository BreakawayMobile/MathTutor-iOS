//
//  FeaturedViewController.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 7/14/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BMMobilePackage
import ScrollableStackView

class FeaturedViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let configController = ConfigController.sharedInstance
    
    fileprivate var heroCarousel: MTFeaturedHeroView!
    fileprivate var newCourses: MTCoursesView!
    
    var dataManager = BCGSDataManager.sharedInstance
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = "APP_NAME".localized(ConfigController.sharedInstance.stringsFilename)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.textColor = UIColor.white
        
        if let font = UIFont(name: Style.Font.Gotham.bold.rawValue, size: 16) {
            label.font = font
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Style.Color.menu1Blue
            if let navBar = self.navigationController?.navigationBar {
                navBar.standardAppearance = appearance
                navBar.scrollEdgeAppearance = navBar.standardAppearance
            }
        } else {
            self.navigationController?.navigationBar.backgroundColor = Style.Color.menu1Blue
        }

        self.navigationController?.navigationBar.topItem?.titleView = label
        
        if let view = UIView.fromNib(nibName: MTFeaturedHeroView.nibName) as? MTFeaturedHeroView {
            self.heroCarousel = view
            self.heroCarousel.setCourseItems(dataManager.heroPlaylists())
            self.heroCarousel.sizeToFit()
            stackView.addArrangedSubview(self.heroCarousel)
        }
        
        if let view = UIView.fromNib(nibName: MTCoursesView.nibName) as? MTCoursesView {
            self.newCourses = view
            self.newCourses.config(with: dataManager.initialPlaylists(), parentVC: self)
            self.newCourses.sizeToFit()
            stackView.addArrangedSubview(self.newCourses)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.heroCarousel?.viewWillAppear()
        self.newCourses?.viewWillAppear()
        self.enableNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkForAlerts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.heroCarousel?.viewWillDisappear()
        self.disableNotifications()
    }
    
    // MARK: - Memory
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notifications
    
    func enableNotifications() {
        let name = NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FeaturedViewController.productPurchased(_:)),
                                               name: name,
                                               object: nil)
        
    }
    
    // swiftlint:disable notification_center_detachment
    func disableNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    // swiftlint:enable notification_center_detachment
    
    @objc func productPurchased(_ notification: Notification) {
        if let productIdentifier = notification.object as? String {
            if productIdentifier == MTProducts.MonthlySubscription {
                self.newCourses?.viewWillAppear()
                self.checkForAlerts()
            }
        }
    }

    // MARK: - Size Class
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.heroCarousel?.sizeChanged()
        self.newCourses?.sizeChanged()
    }
    
    private func checkForAlerts() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let stringsFile = self.configController.stringsFilename else {
            fatalError("Exected an AppDelegate object")
        }
        
        if appDelegate.showSubExpiredAlert() {
            appDelegate.clearSubscriptionExpireAlert()
            
            let alertController = UIAlertController(title: "",
                                                    message: "SUBSCRIPTION_EXPIRED_MSG".localized(stringsFile),
                                                    preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK".localized(stringsFile),
                                              style: .default,
                                              handler: nil)
            alertController.addAction(defaultAction)
            
            appDelegate.display(alert: alertController)
        }
        
        if appDelegate.showSubRestoredAlert() {
            appDelegate.clearSubscriptionRestoreAlert()
            
            let alertController = UIAlertController(title: "",
                                                    message: "SUBSCRIPTION_RESTORED_MSG".localized(stringsFile),
                                                    preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK".localized(self.configController.stringsFilename),
                                              style: .default,
                                              handler: nil)
            alertController.addAction(defaultAction)
            
            appDelegate.display(alert: alertController)
        }
    }
}
