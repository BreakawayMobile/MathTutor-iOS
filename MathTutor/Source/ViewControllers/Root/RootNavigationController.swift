//
//  RootNavigationController.swift
//  Lightbox
//
//  Created by Matthew Daigle on 6/19/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController {

    // MARK: - Properties

//    weak var navBarTabMenu: TabMenu?

    // MARK: - Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1 {
            // iOS 6.1 or earlier
            self.navigationController?.navigationBar.tintColor = UIColor.white
        } else {
            // iOS 7.0 or later
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.isTranslucent = false
        }
        
        // Tewmp: use: "100203" for "Series" screen (30 Rock)
        let vc = Controllers.featuredViewController()
        viewControllers = [vc]

        setBarButtonItems(animated: false)
//        setNavBarTabMenu()
//        addNotificationListeners()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        navBarTabMenu?.menuTitles = ["HOME", "TV", "MOVIES", "KIDS"]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        if !SessionContext.isUserLoggedIn && !SessionContext.shouldBrowseAsGuest {
//            presentLogin()
//        }
    }

    // MARK: - UI Configuration

    private func setBarButtonItems(animated: Bool) {
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "hamburger"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(menuButtonTapped))
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Search"), style: .plain, target: self, action: #selector(searchButtonTapped))
//        let loginButton = loginBarButtonItem()
//        let chromecastButton = UIBarButtonItem(image: #imageLiteral(resourceName: "chromecast"), style: .plain, target: self, action: #selector(chromecastButtonTapped))
//        let logoItem = logoBarButtonItem()

//        let leftBarButtonItems = UIDevice.isPhone ? [menuButton] : [menuButton, logoItem]
//        let rightBarButtonItems = [searchButton] //SessionContext.isUserLoggedIn ? [searchButton, chromecastButton] : [loginButton, searchButton]

        topViewController?.navigationItem.setLeftBarButton(menuButton, animated: false)
        topViewController?.navigationItem.setRightBarButton(searchButton, animated: false)
        
//        topViewController?.navigationItem.setLeftBarButtonItems(leftBarButtonItems, animated: animated)
//        topViewController?.navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: animated)
    }

    private func loginBarButtonItem() -> UIBarButtonItem {
        let color = UIDevice.isPad ? .white : Style.Color.sunflowerYellow
        let login = UIButton()
        login.cornerRadius = 3
        login.borderWidth = 1.5
        login.borderColor = color
        login.setTitleColor(color, for: .normal)
        if UIDevice.isPad {
            login.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 7, right: 16)
        }
        else {
            login.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 7, right: 8)
        }
        login.setTitle("LOGIN".localized.uppercased(), for: .normal)
        login.titleLabel?.font = Style.Font.with(family: .gothamRounded, style: .medium, size: 15)
        login.sizeToFit()
        login.addTarget(self, action: #selector(presentLogin), for: .touchUpInside)

        return UIBarButtonItem(customView: login)
    }

    private func logoBarButtonItem() -> UIBarButtonItem {
        let logoImage = #imageLiteral(resourceName: "MathTutor_Logo_White")
        let aspectRatio = logoImage.size.width / logoImage.size.height
        let height: CGFloat = 26
        let width = ceil(height * aspectRatio)

        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = logoImage

        return UIBarButtonItem(customView: logoImageView)
    }

//    private func setNavBarTabMenu() {
//        guard UIDevice.isPad else { return }
//
//        if let tabMenu = TabMenu.fromNib() as? TabMenu {
//            tabMenu.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(tabMenu)
//            view.addConstraint(NSLayoutConstraint(item: tabMenu, attribute: .bottom, relatedBy: .equal, toItem: navigationBar, attribute: .bottom, multiplier: 1, constant: 0))
//            view.addConstraint(NSLayoutConstraint(item: tabMenu, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
//            view.addConstraint(NSLayoutConstraint(item: tabMenu, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.width - 350))
//            view.addConstraint(NSLayoutConstraint(item: tabMenu, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
//
//            navBarTabMenu = tabMenu
//        }
//    }

    // MARK: - Notification Listeners

//    private func addNotificationListeners() {
//        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: GlobalConstants.Notifications.userDidLogin, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: GlobalConstants.Notifications.userDidLogout, object: nil)
//    }

    @objc private func userLoggedIn() {
        setBarButtonItems(animated: true)
    }

    @objc private func userLoggedOut() {
        setBarButtonItems(animated: true)
    }

    // MARK: - Navigation

    @objc private func presentLogin() {
//        let vc = Controllers.loginViewController()
//        present(vc, animated: true, completion: nil)
    }

    private func presentSearch() {
        Controllers.search()
    }

    // MARK: - IBActions

    @IBAction func chromecastButtonTapped(_ sender: UIBarButtonItem) {

    }

    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        slideMenuController()?.toggleLeft()
    }

    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        presentSearch()
    }
}
