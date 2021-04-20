//
//  GlobalConstants.swift
//  Lightbox
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import Foundation
import UIKit

struct GlobalConstants {

    struct Notifications {
        static let userFavoriteChanged = Notification.Name("userFavoriteChanged")
        static let backendDataRefresh = Notification.Name("backendDataRefresh")
    }

    struct Animation {
        static let defaultDuration = TimeInterval(0.3)
        static let defaultDelay = TimeInterval(0.3)
    }
    
    struct Maximum {
        static let favoriteCount = 100
        static let recentCount = 100
    }
}
