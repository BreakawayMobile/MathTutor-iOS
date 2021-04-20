//
//  PlayProgress+CoreDataProperties.swift
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

open class PlayProgress: RealmSwift.Object {

    @objc open dynamic var videoId = ""
    @objc open dynamic var currentPosition: Double = 0
    @objc open dynamic var lastUpdate = Date()
    
    open override static func primaryKey() -> String? {
        return "videoId"
    }

    public static func findProgress(_ videoId: String,
                                    storage: Storage,
                                    completion: ((PlayProgress?) -> Void)!) {
        
        let predicate = NSPredicate(format: "videoId == '\(videoId)'")

        if Thread.isMainThread {
            if let context = storage.mainContext {
                PlayProgress.fetch(progressItem: context,
                                   predicate: predicate,
                                   completion: completion)
            }
            
            return
        }
        
        storage.performBackgroundTask { backgroundContext in
            guard let backgroundContext = backgroundContext else { return }
            
            PlayProgress.fetch(progressItem: backgroundContext,
                               predicate: predicate,
                               completion: completion)
        }
    }
    
    static func fetch(progressItem context: StorageContext,
                      predicate: NSPredicate,
                      completion: ((PlayProgress?) -> Void)!) {
        
        do {
            try context.fetch(predicate: predicate,
                          sortDescriptors: nil,
                          completion: { (entities: [PlayProgress]?) in
                if let item = entities?.first {
                    completion?(item)
                } else {
                    completion?(nil)
                }
            })
        } catch {
            
        }
    }
    
    public static func playProgress(for videoId: String,
                                    storage: Storage,
                                    completion: ((Double) -> Void)!) {
        
        let predicate = NSPredicate(format: "videoId == \(videoId)")

        if Thread.isMainThread {
            if let context = storage.mainContext {
                PlayProgress.fetch(progressPosition: context,
                                   predicate: predicate,
                                   completion: completion)
            }
            
            return
        }
        
        storage.performBackgroundTask { backgroundContext in
            guard let backgroundContext = backgroundContext else { return }
            
            PlayProgress.fetch(progressPosition: backgroundContext,
                               predicate: predicate,
                               completion: completion)
        }
    }

    static func fetch(progressPosition context: StorageContext,
                      predicate: NSPredicate,
                      completion: ((Double) -> Void)!) {
        
        do {
            try context.fetch(predicate: predicate,
                          sortDescriptors: nil,
                          completion: { (entities: [PlayProgress]?) in
                            
                if let item = entities?.first {
                    completion?(item.currentPosition)
                } else {
                    completion?(0)
                }
            })
        } catch {
            
        }
    }

    public static func update(progress value: Double,
                              for videoId: String,
                              storage: Storage) {
        
        if Thread.isMainThread {
            if let context = storage.mainContext {
                PlayProgress.update(progressObject: context,
                                    value: value,
                                    for: videoId,
                                    storage: storage)
            }
            
            return
        }
        
        storage.performBackgroundTask { backgroundContext in
            guard let backgroundContext = backgroundContext else { return }
            
            PlayProgress.update(progressObject: backgroundContext,
                                value: value,
                                for: videoId,
                                storage: storage)
        }
    }
    
    static func update(progressObject context: StorageContext,
                       value: Double,
                       for videoId: String,
                       storage: Storage) {
        
        PlayProgress.findProgress(videoId, storage: storage) { (progress) in
            if let progressObject = progress {
                // Update
                do {
                    try context.update {
                        progressObject.currentPosition = value
                        progressObject.lastUpdate = Date()
                        print("Progress Object Updated")
                        
                        MTUser.update(progressObject,
                                      storage: storage,
                                      context: context)
                    }
                } catch {}
            } else {
                // Create
                do {
                    if let progressObject: PlayProgress = try context.create() {
                        progressObject.videoId = videoId
                        progressObject.currentPosition = value
                        progressObject.lastUpdate = Date()
                        
                        try context.addOrUpdate(progressObject)
                        print("Progress Object Added")
                        
                        MTUser.update(progressObject,
                                      storage: storage,
                                      context: context)
                    }
                } catch {}
            }
        }
    }
    
    static func get(recents storage: Storage,
                    completion: (([PlayProgress]) -> Void)!) {
        if Thread.isMainThread {
            if let context = storage.mainContext {
                PlayProgress.fetch(progressObjects: context,
                                   storage: storage,
                                   completion: completion)
            }
            
            return
        }
        
        storage.performBackgroundTask { backgroundContext in
            guard let backgroundContext = backgroundContext else { return }
            
            PlayProgress.fetch(progressObjects: backgroundContext,
                               storage: storage,
                               completion: completion)
        }
    }
    
    static func fetch(progressObjects context: StorageContext,
                      storage: Storage,
                      completion: (([PlayProgress]) -> Void)!) {
        
        do {
            let sortByUpdate = SortDescriptor(key: #keyPath(PlayProgress.lastUpdate),
                                              ascending: false)
            
            try context.fetch(predicate: nil,
                          sortDescriptors: [sortByUpdate],
                          completion: { (entities: [PlayProgress]?) in
                            
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
