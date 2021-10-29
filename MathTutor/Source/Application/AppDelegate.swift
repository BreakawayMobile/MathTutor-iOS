//
//  AppDelegate.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 7/11/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import BMMobilePackage
import Crashlytics
import Fabric
import Firebase
import SlideMenuControllerSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BCGSMobileSessionConsumer {

    private enum Constants {
        static let googleConversionId = "1071099651"
        static let googleConversionLabel = "Avk6CMq-pHUQg97e_gM"
        static let googleConversionValue = "0.00"
    }

    static let menuWidth: CGFloat = 340.0

    lazy var cmsController = BGSMobilePackage.sharedInstance.cmsController()

    var window: UIWindow?
    var configController = ConfigController.sharedInstance
    var sessionController = BGSMobilePackage.sharedInstance.sessionController
    var dataManager = BCGSDataManager.sharedInstance
    var sideMenuViewController: UIViewController!
    var rootNavController: RootNavigationController!
    var userManager = MTUserManager.shared
    var dateEnteredBackground: Date!
    var reviewManager = ReviewManager.shared
    
    fileprivate var initialPlaylists: [String] = []
    fileprivate var backgroundPlaylists: [String] = []
    fileprivate var heroPlaylists: [String] = []
    fileprivate var landingPlaylists: [String] = []
    fileprivate var startTime: Date!
    fileprivate var updateTime: Date!
    fileprivate var showSubscritionExpiredAlert: Bool = false
    fileprivate var showSubscritionRestoredAlert: Bool = false
   
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        self.startTime = Date()
        
//        // Google Conversion Tracking
//        ACTAutomatedUsageTracker.enableAutomatedUsageReporting(withConversionID: Constants.googleConversionId)
//        ACTConversionReporter.report(withConversionID: Constants.googleConversionId,
//                                     label: Constants.googleConversionLabel,
//                                     value: Constants.googleConversionValue,
//                                     isRepeatable: false)
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        Style.configureAppearance()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.setRootViewController(to: Controllers.waitingViewController(), for: self.window)
                
        configController.load("MathTutor.json") { (json) in
            if let landingPlaylists = json["landingConfig"] as? [String],
               let heroPlaylists = json["heroConfig"] as? [String] {
                self.heroPlaylists = heroPlaylists
                self.landingPlaylists = landingPlaylists
                self.initialPlaylists = landingPlaylists + heroPlaylists
            }
            
            var url: URL?
            
            if let remoteUrl = json["remote_url"] as? String {
                if let value = URL(string: remoteUrl) {
                    url = value
                }
            }
            
            MTMenuService.shared.enable(with: url, localFilename: "MathTutor.json") {
                self.backgroundPlaylists = MTMenuService.shared.allPlaylists()            
                self.initializeMobileLibrary()
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain
        // types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits
        // the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games
        // should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application
        // state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate:
        // when the user quits.
        self.dateEnteredBackground = Date()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the
        // changes made on entering the background.
        
        if dateEnteredBackground != nil {
            let dateEnteredForgreound = Date()
            let timeInterval = dateEnteredForgreound.timeIntervalSince(dateEnteredBackground)
            
            if BGSMobilePackage.sharedInstance.sessionController().syncIfNeeded(timeInterval) {
                self.startTime = Date()
                self.window?.rootViewController = BCGSAppConfig.sharedInstance.loadWaitingPage()
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the
        // application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.
        // See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
//            ACTConversionReporter.reportUniversalLink(with: userActivity)
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone &&
            UIApplication.topViewController() is MTVideoViewController {
            return .landscape
        }
            
        return .all
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }
    
    // MARK: - Initialization
    
    func initializeMobileLibrary() {
        let bcgsMobileLib = BGSMobilePackage.sharedInstance
        guard let sessionConfig = configController.sessionConfig as? [String: Any] else { return }
        var newSessionConfig = sessionConfig
        newSessionConfig[kCVCStartupPlaylists] = initialPlaylists
        newSessionConfig[kCVCBackgroundPlaylists] = backgroundPlaylists
        bcgsMobileLib.setSessionConfig(newSessionConfig)
        
        guard let playlistConfig = configController.playlistConfig as? [String: Any] else { return }
        bcgsMobileLib.setPlaylistConfig(playlistConfig)
        bcgsMobileLib.setDefaultCMS()
        
//        if configController.useCMS() == false {
            sessionController().addSessionConsumer(self)
//        }
//        else {
//            cmsInitialize()
//        }
        
        #if USEIMA
            if let adConfig = configController.adConfig {
                bcgsMobileLib.addAdControl(withConfig: adConfig)
            }
        #endif
        //        guard let authConfig = configController.authConfig as? [String : Any] else { return }
        //        bcgsMobileLib.setAuthenticationConfig(authConfig)
        
        if let analyticsConfig = configController.analyticsConfig as? [String: Any] {
            bcgsMobileLib.setAnalyticsConfig(analyticsConfig)
        }
    }
    
    func cmsInitialize() {        
        DispatchQueue.main.async {
            if self.window?.rootViewController == nil {
                self.setRootViewController(to: BCGSAppConfig.sharedInstance.loadWaitingPage(), for: self.window)
            }
        }
        
        // Load the menu and main view controllers
        let sideMenuViewController = Controllers.mainMenuViewController()
        self.rootNavController = Controllers.rootNavigationController()
        self.setRootViewController(to: self.rootNavController, for: self.window)
        
        // Configure the menu width and behavior
        SlideMenuOptions.leftViewWidth = AppDelegate.menuWidth
        SlideMenuOptions.contentViewScale = 1.0
        
        let slideMenuController = BCGSMenuContainerViewController(mainViewController: self.rootNavController,
                                                                  leftMenuViewController: sideMenuViewController)
        self.setRootViewController(to: slideMenuController, for: self.window)
    }
    
    // MARK: BCGSMobileSessionConsumer
    
    func didReceiveSessionEvent(_ sessionEvent: String?, with anyObject: Any?) {
        if let event = sessionEvent {
            switch event {
            case kBCGSEventSyncStart:
                DispatchQueue.main.async(execute: {
                    let root = self.window?.rootViewController ?? BCGSAppConfig.sharedInstance.loadErrorPage()
                    let rootMirror = Mirror(reflecting: root)
                    let errorMirror = Mirror(reflecting: Controllers.errorViewController())
                    
                    if self.window?.rootViewController == nil || (rootMirror.subjectType == errorMirror.subjectType) {
                        self.window?.rootViewController = BCGSAppConfig.sharedInstance.loadWaitingPage()
                    }
                })
                return
                
            case kBCGSEventSyncUpdate:
                self.updateTime = Date()
                print("Update Time: \(self.updateTime.timeIntervalSince(self.startTime))")
                
                if let allPlaylists = anyObject as? [BCGSPlayList] {
                    let landingPlaylistCount = self.heroPlaylists.count + self.landingPlaylists.count
                    print("**** PLAYLIST ****: kBCGSEventSyncUpdate: playlist count = \(allPlaylists.count)")
                    print("**** PLAYLIST ****: kBCGSEventSyncUpdate: playlist max = \(landingPlaylistCount)")
                    if allPlaylists.count < landingPlaylistCount {
                        DispatchQueue.main.async {
                            if let waitingVC = self.window?.rootViewController as? MTWaitingViewController {
                                waitingVC.setProgress(allPlaylists.count, max: landingPlaylistCount)
                            }
                        }
                    } else {
                        DispatchQueue.global().async {
                            if allPlaylists.count != self.dataManager.allPlaylists.count {
                                self.dataManager.allPlaylists = allPlaylists
                                self.dataManager.setHeroPlaylists(self.heroPlaylists)
                                self.dataManager.setInitialPlaylists(self.landingPlaylists)
                                
                                DispatchQueue.main.async(execute: {
                                    self.loadInitialViewControllers()
                                    
                                    NotificationCenter.default.post(name: GlobalConstants.Notifications.backendDataRefresh,
                                                                    object: nil)
                                })
                            }
                        }
                    }
                }
                else {
                    // AssertUtilities.logAndAssert(false, "allPlaylists not found")
                    NSLog( "allPlaylists not found")
                }
                return
            case kBCGSEventSyncUnchanged:
                return
            case kBCGSEventSyncFail:
                DispatchQueue.main.async(execute: {
                    let root = self.window?.rootViewController ?? BCGSAppConfig.sharedInstance.loadWaitingPage()
                    let rootMirror = Mirror(reflecting: root)
                    let waitingMirror = Mirror(reflecting: BCGSAppConfig.sharedInstance.loadWaitingPage())
                    
                    if (rootMirror.subjectType == waitingMirror.subjectType) {
                        self.window?.rootViewController = Controllers.errorViewController()
                    }
                })
                return
            default:
                return
            }
        }
    }
    
    func loadInitialViewControllers() {
        if !(self.window?.rootViewController is BCGSMenuContainerViewController) {
            let sideMenuViewController = Controllers.mainMenuViewController()
            self.rootNavController = Controllers.rootNavigationController()
            self.setRootViewController(to: self.rootNavController, for: self.window)
            
            // Configure the menu width and behavior
            SlideMenuOptions.leftViewWidth = AppDelegate.menuWidth
            SlideMenuOptions.contentViewScale = 1.0
            
            let slideMenuController = BCGSMenuContainerViewController(mainViewController: self.rootNavController,
                                                                      leftMenuViewController: sideMenuViewController)
            self.setRootViewController(to: slideMenuController, for: self.window)
        }
    }

    // MARK: - Root View Controller
    
    private func setRootViewController(to viewController: UIViewController?, for window: UIWindow?) {
        // You need to remove subviews from a window before changing the root view controller.
        // H/T: http://stackoverflow.com/a/17668744/511287
        for subview in window?.subviews ?? [] {
            subview.removeFromSuperview()
        }
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Top View Controller
    
    func topViewController() -> UIViewController! {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        return self.topViewControllerWithRootViewController(keyWindow?.rootViewController)
    }
    
    func topViewControllerWithRootViewController(_ rootViewController: UIViewController!) -> UIViewController! {
        if rootViewController is UITabBarController {
            if let tabBarController = rootViewController as? UITabBarController {
                return self.topViewControllerWithRootViewController(tabBarController.selectedViewController)
            }
        } else if rootViewController is UINavigationController {
            if let navController = rootViewController as? UINavigationController {
                return self.topViewControllerWithRootViewController(navController.visibleViewController)
            }
        }
            //        else if rootViewController is BCGSMenuContainerViewController {
            //            let menuController = rootViewController as! BCGSMenuContainerViewController
            //            return menuController.mainViewController
            //        }
        else if rootViewController?.presentedViewController != nil {
            return self.topViewControllerWithRootViewController(rootViewController.presentedViewController)
        }
        
        return rootViewController
    }
    
    func display(alert avc: UIAlertController) {
        DispatchQueue.main.async {
            self.topViewController().present(avc, animated: true, completion: nil)
        }
    }
    
    func subScriptionAlert() {
        self.showSubscritionExpiredAlert = true
    }
    
    func showSubExpiredAlert() -> Bool {
        return self.showSubscritionExpiredAlert
    }
    
    func clearSubscriptionExpireAlert() {
        self.showSubscritionExpiredAlert = false
    }
    
    func subScriptionRestoredAlert() {
        self.showSubscritionRestoredAlert = true
    }
    
    func showSubRestoredAlert() -> Bool {
        return self.showSubscritionRestoredAlert
    }
    
    func clearSubscriptionRestoreAlert() {
        self.showSubscritionRestoredAlert = false
    }
}

