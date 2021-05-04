//
//  Favorite.swift
//  
//
//  Created by Joseph Radjavitch on 6/10/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import class RealmSwift.Object
import Realm
import StorageKit

open class Favorite: RealmSwift.Object {

    @objc open dynamic var videoId = ""
    @objc open dynamic var title = ""
    
    public override static func primaryKey() -> String? {
        return "videoId"
    }
    
    public static func findFavorite(_ videoId: String,
                                    storage: Storage,
                                    completion: ((Favorite?) -> Void)!) {
        
        let predicate = NSPredicate(format: "videoId == '\(videoId)'")
        
        if Thread.isMainThread {
            if let context = storage.mainContext {
                Favorite.fetch(favoriteItem: context,
                               predicate: predicate,
                               completion: completion)
            }
            
            return
        }
        
        storage.performBackgroundTask { backgroundContext in
            guard let backgroundContext = backgroundContext else { return }
            
            Favorite.fetch(favoriteItem: backgroundContext,
                           predicate: predicate,
                           completion: completion)
        }
    }
    
    static func fetch(favoriteItem context: StorageContext,
                      predicate: NSPredicate,
                      completion: ((Favorite?) -> Void)!) {
        
        do {
            try context.fetch(predicate: predicate,
                          sortDescriptors: nil,
                          completion: { (entities: [Favorite]?) in
                if let item = entities?.first {
                    completion?(item)
                } else {
                    completion?(nil)
                }
            })
        } catch {
            
        }
    }
    
    static func add(favorite videoId: String,
                    title: String,
                    context: StorageContext,
                    storage: Storage,
                    completion: (() -> Void)!) {
        
        Favorite.findFavorite(videoId, storage: storage, completion: { (favorite) in
            if let favoriteObject = favorite {
                // Update
                do {
                    try context.update {
                        print("Favorite Already Exists")
                        
                        MTUser.add(favoriteObject,
                                   storage: storage,
                                   context: context)
                        
                        completion?()
                        
                        let name = GlobalConstants.Notifications.userFavoriteChanged
                        NotificationCenter.default.post(name: name,
                                                        object: nil)
                    }
                } catch {}
            } else {
                // Create
                do {
                    if let favoriteObject: Favorite = try context.create() {
                        favoriteObject.videoId = videoId
                        favoriteObject.title = title
                        
                        try context.addOrUpdate(favoriteObject)
                        print("Favorite Object Added")
                        
                        MTUser.add(favoriteObject,
                                   storage: storage,
                                   context: context)
                        
                        ReviewManager.shared.favoriteAdded()
                        
                        completion?()
                        
                        let name = GlobalConstants.Notifications.userFavoriteChanged
                        NotificationCenter.default.post(name: name,
                                                        object: nil)
                    }
                } catch {}
            }
        })
    }
    
    static func remove(favorite videoId: String,
                       context: StorageContext,
                       storage: Storage,
                       completion: (() -> Void)!) {
        
        Favorite.findFavorite(videoId, storage: storage, completion: { (favorite) in
            if let favoriteObject = favorite {
                // Remove
                do {
                    print("Favorite Exists")
                    
                    MTUser.remove(favoriteObject,
                                  storage: storage,
                                  context: context)
                    
                    try context.delete(favoriteObject)
                    completion?()
                    
                    let name = GlobalConstants.Notifications.userFavoriteChanged
                    NotificationCenter.default.post(name: name,
                                                    object: nil)
                } catch {}
            } else {
                completion?()
                
                let name = GlobalConstants.Notifications.userFavoriteChanged
                NotificationCenter.default.post(name: name,
                                                object: nil)
            }
        })
    }
    
    static func exists(favorite videoId: String,
                       storage: Storage,
                       completion: ((Bool) -> Void)!) {
        
        Favorite.findFavorite(videoId, storage: storage, completion: { (favorite) in
            completion?(favorite != nil)
        })
    }
    
    static func get(recents storage: Storage,
                    completion: (([Favorite]) -> Void)!) {
        if Thread.isMainThread {
            if let context = storage.mainContext {
                Favorite.fetch(favoriteObjects: context,
                               storage: storage,
                               completion: completion)
            }
            
            return
        }
        
        storage.performBackgroundTask { backgroundContext in
            guard let backgroundContext = backgroundContext else { return }
            
            Favorite.fetch(favoriteObjects: backgroundContext,
                           storage: storage,
                           completion: completion)
        }
    }
    
    static func fetch(favoriteObjects context: StorageContext,
                      storage: Storage,
                      completion: (([Favorite]) -> Void)!) {
        
        do {
            let sortByTitle = SortDescriptor(key: #keyPath(Favorite.title),
                                             ascending: true)
            
            try context.fetch(predicate: nil,
                          sortDescriptors: [sortByTitle],
                          completion: { (entities: [Favorite]?) in
                
                if let item = entities {
                    completion?(item)
                } else {
                    completion?([])
                }
            })
        } catch {
            
        }
    }
}
