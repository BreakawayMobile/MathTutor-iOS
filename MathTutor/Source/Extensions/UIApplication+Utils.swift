//
//  UIApplication+Utils.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/26/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

extension UIApplication {

    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }

        if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }

        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }

        return controller
    }
    
    class func releaseVersionNumber() -> String {
        if let infoDictionary = Bundle.main.infoDictionary,
            let version = infoDictionary["CFBundleShortVersionString"] as? String {
            return version
        }
        else { return String() }
    }
    
    class func buildVersionNumber() -> String {
        if let infoDictionary = Bundle.main.infoDictionary,
            let version = infoDictionary["CFBundleVersion"] as? String {
            return version
        }
        else { return String() }
    }
}
