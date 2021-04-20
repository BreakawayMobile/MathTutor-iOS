//
//  Configuration.swift
//  Lightbox
//
//  Created by Joseph Radjavitch on 6/27/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class Configuration: NSObject {
    
    static let kDefaultMiddlewareURL = "http://lbx-dev.brightcove.gs/"
    
    fileprivate static var dict: NSDictionary! = nil

    class var LightboxMiddlewareBaseURL: String {
        if dict == nil {
            if let bundle = Bundle.main.path(forResource: "Info", ofType: "plist"),
               let tempDict = NSDictionary(contentsOfFile: bundle) {
                self.dict = tempDict
            }
        }
        
        guard let baseURLString = dict?.object(forKey: "lbxMiddlewareBaseURL") as? String
            else {
                return kDefaultMiddlewareURL
        }
        return baseURLString
    }

}
