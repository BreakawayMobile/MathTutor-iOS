//
//  BCGSVideoExtensions.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/14/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import BMMobilePackage
import UIKit

extension BCGSVideo {
    
    func requiresSubscription() -> Bool {
        if let value = self.customFields?["subscription_required"] as? NSString {
            return value.boolValue
        }
        
        return false
    }

    func relatedDocument() -> String {
        if let value = self.customFields?["relateddocument"] as? String {
            return value
        }
        
        return ""
    }
    
    func setSubscription(_ value: Bool) {
        
    }
}
