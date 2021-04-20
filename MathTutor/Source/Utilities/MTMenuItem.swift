//
//  MenuItem.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 7/31/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import BMMobilePackage
import Foundation
import UIKit

@objc open class MTMenuItem: NSObject {
    
    fileprivate let kNameKey = "name"
    fileprivate let kPlaylistKey = "playlist"
    fileprivate let kChildrenKey = "children"
    
    open var name: String! = ""
    open var playlist: String! = ""
    open var parent: MTMenuItem!
    open var children: [MTMenuItem] = []
    
    fileprivate var preRollGroup = DispatchGroup()
    
    open class func build(with dictionary: [String: Any], parent: MTMenuItem!, completion: ((MTMenuItem) -> Void)?) {
        _ = MTMenuItem(dictionary: dictionary, parent: parent, completion: completion)
    }
    
    private override init() {
    }
    
    private convenience init(dictionary: [String: Any], parent: MTMenuItem!, completion: ((MTMenuItem) -> Void)?) {
        self.init()
        self.configure(with: dictionary, parent: parent, completion: completion)
    }
    
    private func configure(with dict: [String: Any], parent: MTMenuItem!, completion: ((MTMenuItem) -> Void)?) {
        self.parent = parent
        
        if let value = dict[kNameKey] as? String {
            self.name = value
        }
        
        if let value = dict[kPlaylistKey] as? String {
            if value != "" {
                self.playlist = value
            }
        }
        
        if let value = dict[kChildrenKey] as? [[String: Any]] {
            self.children.removeAll()
            
            for dictItem in value {
                self.preRollGroup.enter()
                MTMenuItem.build(with: dictItem, parent: self) { (child: MTMenuItem) in
                    self.children.append(child)
                    self.preRollGroup.leave()
                }
            }
        }
        
        self.preRollGroup.notify(queue: DispatchQueue.main) {
            completion?(self)
        }
    }
    
    func playlists() -> [String] {
        if !(self.playlist ?? "").isEmpty {
            return [self.playlist]
        }
        
        var retVal: [String] = []
        
        for item in children {
            retVal.append(contentsOf: item.playlists())
        }
        
        return retVal
    }
    
    func makeMenu(_ parentLevel: Int) -> MenuBase {
        if self.playlist != nil && self.playlist != "" {
            return MenuItem(name: self.name, level: parentLevel+1, playlist: self.playlist)
        }
        
        var menuItems: [MenuBase] = []
        
        for item in self.children {
            menuItems.append(item.makeMenu(parentLevel+1))
        }
        
        return Section(name: self.name, level: parentLevel+1, items: menuItems)
    }
}
