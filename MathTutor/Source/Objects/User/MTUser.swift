//
//  MTUser.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/11/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import Realm
import RealmSwift
import StorageKit
import UIKit

protocol MTUserDelegate: class {
    func favoritesChanged()
}

class MTUser: RealmSwift.Object {
    open dynamic var name = ""
    open dynamic var subscribed = false
    open var favorites = List<Favorite>()
    open var playProgress = List<PlayProgress>()
    
    override open static func primaryKey() -> String? {
        return "name"
    }

    public static func findUser(_ username: String, storage: Storage, completion: ((MTUser?) -> Void)!) {
        storage.performBackgroundTask { (backgroundContext, _) in
            guard let backgroundContext = backgroundContext else { return }
            let predicate = NSPredicate(format: "name == '\(username)'")
            
            backgroundContext.fetch(predicate: predicate,
                                    sortDescriptors: nil,
                                    completion: { (entities: [MTUser]?) in
                if let item = entities?.first {
                    completion?(item)
                } else {
                    completion?(nil)
                }
            })
        }
    }
    
    public static func initialize(_ username: String, storage: Storage, completion: ((MTUser?) -> Void)!) {
        storage.performBackgroundTask { (backgroundContext, _) in
            guard let backgroundContext = backgroundContext else { return }
            
            MTUser.findUser(username, storage: storage) { (user) in
                if let userObject = user {
                    print("User Object Retrieved")
                    completion?(userObject)
                } else {
                    // Create
                    do {
                        if let userObject: MTUser = try backgroundContext.create() {
                            userObject.name = username
                            try backgroundContext.add(userObject)
                            
                            print("User Object Added")
                            completion?(userObject)
                        }
                    } catch {}
                }
            }
        }
    }
    
    public static func current(storage: Storage, completion: ((MTUser?) -> Void)!) {
        if Thread.isMainThread {
            if let context = storage.mainContext {
                MTUser.fetch(user: context,
                             completion: completion)
            }
            
            return
        }
        
        storage.performBackgroundTask { (backgroundContext, _) in
            guard let backgroundContext = backgroundContext else { return }
            
            MTUser.fetch(user: backgroundContext,
                         completion: completion)
        }
    }
    
    static func fetch(user context: StorageContext,
                      completion: ((MTUser?) -> Void)!) {
        
        context.fetch(predicate: nil,
                      sortDescriptors: nil,
                      completion: { (entities: [MTUser]?) in
            if let item = entities?.first {
                completion?(item)
            } else {
                completion?(nil)
            }
        })
    }

    public static func update(_ progress: PlayProgress,
                              storage: Storage,
                              context: StorageContext) {
        
        MTUser.current(storage: storage, completion: { (user) in
            if let user = user {
                do {
                    try context.update {
                        if !(user.playProgress.contains(progress)) {
                            user.playProgress.insert(progress, at: 0)
                        } else {
                            if let index = user.playProgress.index(of: progress) {
                                user.playProgress.move(from: index, to: 0)
                            }
                        }
                    }
                } catch {}
            }
        })
    }
    
    public static func add(_ favorite: Favorite,
                           storage: Storage,
                           context: StorageContext) {
        
        MTUser.current(storage: storage, completion: { (user) in
            if let user = user {
                do {
                    try context.update {
                        if !(user.favorites.contains(favorite)) {
                            user.favorites.append(favorite)
                        }
                    }
                } catch {}
            }
        })
    }
    
    public static func remove(_ favorite: Favorite,
                              storage: Storage,
                              context: StorageContext) {
        
        MTUser.current(storage: storage, completion: { (user) in
            if let user = user {
                do {
                    try context.update {
                        if (user.favorites.contains(favorite)) {
                            if let index = user.favorites.index(of: favorite) {
                                user.favorites.remove(objectAtIndex: index)
                            }
                        }
                    }
                } catch {}
            }
        })
    }
    
    public static func subscribed(storage: Storage, completion: ((Bool)->Void)! = nil) {
//        storage.performBackgroundTask { (backgroundContext, _) in
//            guard let backgroundContext = backgroundContext else { return }
//            
//            do {
//                try backgroundContext.update {
//                    self.subscribed = true
//                }
//            } catch {}
//        }
        if Thread.isMainThread {
            if let context = storage.mainContext {
                MTUser.fetch(user: context, completion: { (user) in
                    guard let user = user else {
                        fatalError("Expected a User object")
                    }
                    
                    do {
                        try context.update {
                            let dataChanged = user.subscribed == false
                            user.subscribed = true
                            completion?(dataChanged)
                        }
                    } catch {}
                })
            }
            
            return
        }
        
        storage.performBackgroundTask { (backgroundContext, _) in
            guard let backgroundContext = backgroundContext else { return }
            
            MTUser.fetch(user: backgroundContext, completion: { (user) in
                guard let user = user else {
                    fatalError("Expected a User object")
                }
                
                do {
                    try backgroundContext.update {
                        let dataChanged = user.subscribed == false
                        user.subscribed = true
                        completion?(dataChanged)
                    }
                } catch {}
            })
        }
    }
    
    public static func unsubscribed(storage: Storage, completion: ((Bool)->Void)! = nil) {
//        storage.performBackgroundTask { (backgroundContext, _) in
//            guard let backgroundContext = backgroundContext else { return }
//            
//            do {
//                try backgroundContext.update {
//                    self.subscribed = false
//                }
//            } catch {}
//        }        
        if Thread.isMainThread {
            if let context = storage.mainContext {
                MTUser.fetch(user: context, completion: { (user) in
                    guard let user = user else {
                        fatalError("Expected a User object")
                    }
                    
                    do {
                        try context.update {
                            let dataChanged = user.subscribed == true
                            user.subscribed = false
                            completion?(dataChanged)
                        }
                    } catch {}
                })
            }
            
            return
        }
        
        storage.performBackgroundTask { (backgroundContext, _) in
            guard let backgroundContext = backgroundContext else { return }
            
            MTUser.fetch(user: backgroundContext, completion: { (user) in
                guard let user = user else {
                    fatalError("Expected a User object")
                }
                
                do {
                    try backgroundContext.update {
                        let dataChanged = user.subscribed == true
                        user.subscribed = false
                        completion?(dataChanged)
                    }
                } catch {}
            })
        }
    }
}
