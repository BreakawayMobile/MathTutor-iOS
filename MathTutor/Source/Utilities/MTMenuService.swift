//
//  MTMenuService.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 7/31/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import BMMobilePackage
import Foundation

@objc open class MTMenuService: NSObject {
    
    open static let shared = MTMenuService()
    
    fileprivate var isEnabled: Bool = false
    fileprivate var menuItems: [MTMenuItem] = []
    fileprivate var menuItemGroup = DispatchGroup()
    fileprivate var menuItemSemaphore = DispatchSemaphore(value: 1) // 1
    
    open func enable(with url: URL?, localFilename: String, completion: (() -> Void)?) {
        
        let (jsonError, decodedJson) = getLocalJSON(localFilename)
        
        if jsonError != nil {
            print("Error Parsing configuration file")
        }
        else {
            guard let remoteURL = url?.absoluteString, remoteURL != "" else {
                self.parseJSON(decodedJson, completion: completion)
                return
            }
            
            getRemoteJSON(remoteURL, completion: { (error, remoteJson) in
                if let jsonDict = remoteJson as? [String: Any], error == nil {
                    self.parseJSON(jsonDict, completion: completion)
                }
                else {
                    self.parseJSON(decodedJson, completion: completion)
                }
            })
        }
    }
    
    open func allPlaylists() -> [String] {
        var retVal: [String] = []
        
        for item in menuItems {
            retVal.append(contentsOf: item.playlists())
        }
        
        return retVal
    }
    
    open func buildMenu() -> [MenuBase] {
        var retVal: [MenuBase] = []
        guard let stringsFile = ConfigController.sharedInstance.stringsFilename else {
            fatalError("Could not get strings filename.")
        }
        
        // Add FAVORITES menu item
        let favoritesTitle = "FAVORITES_TITLE".localized(stringsFile)
        let favoritesItem = MenuItem(name: favoritesTitle,
                                     level: 0,
                                     playlist: favoritesTitle)
        retVal.append(favoritesItem)

        // Add FAVORITES menu item
        let recentTitle = "RECENT_TITLE".localized(stringsFile)
        let recentItem = MenuItem(name: recentTitle,
                                     level: 0,
                                     playlist: recentTitle)
        retVal.append(recentItem)
        
        // Build remaining menu items
        for item in self.menuItems {
            retVal.append(item.makeMenu(-1))
        }
        
        var aboutItems: [MenuBase] = []
        
        // Add ABOUT_INSTRUCTOR menu item
        let instructorTitle = "ABOUT_INSTRUCTOR".localized(stringsFile)
        let instructorItem = MenuItem(name: instructorTitle,
                                      level: 1,
                                      playlist: instructorTitle)
        aboutItems.append(instructorItem)
        
        // Add SUBSCRIPTION_INFO menu item
        let subscriptionTitle = "SUBSCRIPTION_INFO".localized(stringsFile)
        let subscriptionItem = MenuItem(name: subscriptionTitle,
                                        level: 1,
                                        playlist: subscriptionTitle)
        aboutItems.append(subscriptionItem)
        
        // Add PRIVACY_POLICY menu item
        let privacyTitle = "PRIVACY_POLICY".localized(stringsFile)
        let privacyItem = MenuItem(name: privacyTitle,
                                   level: 1,
                                   playlist: privacyTitle)
        aboutItems.append(privacyItem)
        
        // Add TERMS_OF_USE menu item
        let termsTitle = "TERMS_OF_USE".localized(stringsFile)
        let termsItem = MenuItem(name: termsTitle,
                                 level: 1,
                                 playlist: termsTitle)
        aboutItems.append(termsItem)
        
        let aboutTitle = "ABOUT_US".localized(stringsFile)
        let aboutItem = Section(name: aboutTitle,
                                level: 0,
                                items: aboutItems)

        retVal.append(aboutItem)
        
        return retVal
    }
    
    fileprivate func parseJSON(_ configJson: [String: Any], completion: (() -> Void)?) {
        isEnabled = true
        
        if let rootItemJson = configJson["menu_config"] as? [String: Any],
           let rootItemArray = rootItemJson["items"] as?  [[String: Any]] {
            self.menuItems.removeAll()
            
            self.menuItemGroup.enter()
            DispatchQueue.global().async {
                for (index, tempItem) in rootItemArray.enumerated() {
                    self.menuItemSemaphore.wait()
                    MTMenuItem.build(with: tempItem, parent: nil) { (item: MTMenuItem) in
                        self.menuItems.append(item)
                        self.menuItemSemaphore.signal()
                        
                        if index == rootItemArray.count - 1 {
                            self.menuItemGroup.leave()
                        }
                    }
                }
            }
        
            self.menuItemGroup.notify(queue: DispatchQueue.main) {
                completion?()
            }
        }
    }
    
    fileprivate func getLocalJSON(_ fileName: String) -> (Error?, [String: Any]) {
        let nsFileName = fileName as NSString
        
        guard let filePath = Bundle.main.path(forResource: nsFileName.deletingPathExtension, ofType: nsFileName.pathExtension),
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
                fatalError("Could not get valid data from local JSON")
        }
        
        var jsonError: Error? = nil
        var decodedJson: Any? = nil
        do {
            decodedJson = try JSONSerialization.jsonObject(with: data,
                                                           options: JSONSerialization.ReadingOptions.allowFragments)
        } catch let error {
            jsonError = error
        }
        
        guard let json = decodedJson as? [String: Any] else {
            fatalError("Could not get valid JSON")
        }
        
        return (jsonError, json)
    }
    
    fileprivate typealias JSONCompletionHandler = (Error?, AnyObject?) -> Void
    
    fileprivate func getRemoteJSON(_ urlString: String, completion: JSONCompletionHandler?) {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        guard let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: customAllowedSet),
            let url = URL(string: escapedString) else {
                fatalError("Could not get valid remote URL")
        }
        
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 5
        session.configuration.timeoutIntervalForResource = 5
        session.configuration.requestCachePolicy = .reloadIgnoringCacheData
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let sessionTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard let data = data else {
                completion?(error as Error?, nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, self.isHttpError(httpResponse) {
                var userInfo: [String: String]?
                userInfo = [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)]
                let error = NSError(domain: "UMCURLSession", code: httpResponse.statusCode, userInfo: userInfo)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                    completion?(error, json)
                }
                catch _ {
                    completion?(error, data as AnyObject?)
                }
                
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                completion?(error as Error?, json as AnyObject?)
            } catch let parseError {
                print(parseError)// Log the error thrown by `JSONObjectWithData`
                if let jsonStr = String(data: data, encoding: String.Encoding.utf8) {
                    print("Error could not parse JSON: '\(jsonStr)'")
                    completion?(self.buildParseError(jsonStr), nil)
                }
            }
        })
        
        sessionTask.resume()
    }
    
    fileprivate func isHttpError(_ response: HTTPURLResponse) -> Bool {
        return response.statusCode < 200 || response.statusCode > 299
    }
    
    fileprivate func buildParseError(_ errorString: String) -> Error {
        var userInfo: [String: String]?
        userInfo = [NSLocalizedDescriptionKey: errorString]
        return NSError(domain: "UMCURLSession", code: -1, userInfo: userInfo)
    }
    
    // MARK: - deinit
    
    deinit {
        self.menuItems.removeAll()
    }
}
