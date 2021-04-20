//
//  BCGSDataManagerExtensions.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/3/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BGSMobilePackage

extension BCGSDataManager {
    enum NewProps: String {
        case HeroPlaylists
        case InitialPlaylists
    }

    func setHeroPlaylists(_ heroPlaylistIds: [String]) {
        self.extensionProps[NewProps.HeroPlaylists.rawValue] = playlists(for: heroPlaylistIds)
    }
    
    func heroPlaylists() -> [BCGSPlayList] {
        if let value = self.extensionProps[NewProps.HeroPlaylists.rawValue] as? [BCGSPlayList] {
            return value
        }
        
        return []
    }
    
    func setInitialPlaylists(_ initialPlaylistIds: [String]) {
        self.extensionProps[NewProps.InitialPlaylists.rawValue] = playlists(for: initialPlaylistIds)
    }
    
    func initialPlaylists() -> [BCGSPlayList] {
        if let value = self.extensionProps[NewProps.InitialPlaylists.rawValue] as? [BCGSPlayList] {
            return value
        }
        
        return []
    }
    
    func playlists(for playlists: [String]) -> [BCGSPlayList] {
        var retVal: [BCGSPlayList] = []
        
        for item in playlists {
            if let value = findPlaylistById(item as NSString) {
                retVal.append(value)
            }
        }
        
        return retVal
    }
}
