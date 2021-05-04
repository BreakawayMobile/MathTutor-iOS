//
//  Controllers.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BMMobilePackage

struct Controllers {

    private enum Storyboard: String {
        case Root
        case Login
        case MainMenu
        case LBProfileManager
        case Featured
        case Course
        case MTVideoViewController
        case MTSearchViewController
        case MTConnectionErrorViewController
        case Recent
        case Favorites
        case Waiting
        case MTWebViewController
    }

    // MARK: - View Controllers

    static func rootNavigationController() -> RootNavigationController {
        return instantiateViewController(fromStoryboard: .Root)
    }

//    static func loginViewController() -> LoginViewController {
//        return instantiateViewController(fromStoryboard: .Login)
//    }
//
    static func mainMenuViewController() -> MainMenuViewController {
        return instantiateViewController(fromStoryboard: .MainMenu)
    }

    static func featuredViewController() -> FeaturedViewController {
        return instantiateViewController(fromStoryboard: .Featured)
    }
 
    static func errorViewController() -> MTConnectionErrorViewController {
        return instantiateViewController(fromStoryboard: .MTConnectionErrorViewController)
    }

    static func waitingViewController() -> MTWaitingViewController {
        return instantiateViewController(fromStoryboard: .Waiting)
    }
    
//    static func profileManagerViewController() -> LBProfileManagerViewController {
//        return instantiateViewController(fromStoryboard: .LBProfileManager)
//    }
    
    static func search() {
        let vc = instantiateViewController(fromStoryboard: .MTSearchViewController)
        
        push(viewController: vc)
    }
    
    static func recent() {
        let vc = instantiateViewController(fromStoryboard: .Recent)
        
        push(viewController: vc)
    }
    
    static func favorites() {
        let vc = instantiateViewController(fromStoryboard: .Favorites)
        
        push(viewController: vc)
    }
    
    static func push(with courseID: String, courseTitle: String) {
        let vc = instantiateViewController(fromStoryboard: .Course)
        
        if let courseVC = vc as? MTCourseViewController {
            courseVC.config(with: courseID, courseTitle: courseTitle)
        }
        
        push(viewController: vc)
    }
    
    static func present(with lesson: BCGSVideo) {
        let vc = instantiateViewController(fromStoryboard: .MTVideoViewController)
        
        if let videoVC = vc as? MTVideoViewController {
            videoVC.configure(with: lesson)
        }
        
        vc.modalPresentationStyle = .fullScreen
        present(viewController: vc)
    }

    static func play(_ lesson: BCGSVideo) {
        let storage = BCGSDataManager.sharedInstance.dataStorage()
        MTUser.current(storage: storage) { (user) in
            guard let user = user else {
                return
            }
            
            let subscribed = user.subscribed
            if lesson.requiresSubscription() && subscribed == false {
                DispatchQueue.main.async {
                    MTUserManager.shared.productPurchasePrompt()
                }
                return
            }
            
            DispatchQueue.main.async {
                Controllers.present(with: lesson)
            }
        }
    }
    
    static func open(with url: String) {
        let vc = instantiateViewController(fromStoryboard: .MTWebViewController)
        
        if let webVC = vc as? MTWebViewController {
            webVC.loadURL(url)
        }
        
        push(viewController: vc)
    }
    
    // MARK: - Navigation

    static func push(viewController: UIViewController) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.rootNavController.pushViewController(viewController, animated: true)
    }
    
    static func present(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        UIApplication.topViewController()?.present(viewController, animated: animated, completion: completion)
    }

    // MARK: - Generic Instantiation

    // This works for view controllers with a storyboard ID that is the same as its type name
    private static func instantiateViewController<T: UIViewController>(fromStoryboard storyboard: Storyboard,
                                                                       bundle: Bundle? = nil) -> T {
        return instantiateViewController(withIdentifier: String(describing: T.self),
                                         fromStoryboard: storyboard,
                                         bundle: bundle)
    }

    private static func instantiateInitialViewController<T: UIViewController>(fromStoryboard storyboard: Storyboard,
                                                                              bundle: Bundle? = nil) -> T {
        guard let vc = UIStoryboard(name: storyboard.rawValue,
                                    bundle: bundle).instantiateInitialViewController() as? T else {
            fatalError("Cannot instantiate initial view controller from storyboard \(storyboard)")
        }

        return vc
    }

    private static func instantiateViewController<T: UIViewController>(withIdentifier identifier: String,
                                                                       fromStoryboard storyboard: Storyboard,
                                                                       bundle: Bundle? = nil) -> T {
        guard let vc = UIStoryboard(name: storyboard.rawValue,
                                    bundle: bundle).instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Cannot instantiate view controller with identifier \(identifier) from storyboard \(storyboard)")
        }
        
        return vc
    }
}
