//
//  CuratedList.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/21/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import BMMobilePackage
import UIKit

class CuratedList: NSObject {
    
    let dataManager = BCGSDataManager.sharedInstance

    var items: [BCGSPlayList] = []
    
    init(_ videos: [BCGSVideo]) {
        super.init()
        
        for video in videos {
            if let playlist = dataManager.playlist(for: video) {
                if let index = items.firstIndex(where: { $0.name == playlist.name }) {
                    items[index].videos.append(video)
                } else {
                    if let copyPlaylist = playlist.copy() as? BCGSPlayList {
                        copyPlaylist.videos.removeAll()
                        copyPlaylist.videos.append(video)
                        items.append(copyPlaylist)
                    }
                }
            }
        }
        
        let sortedItems = self.items.sorted(by: { $0.name < $1.name })
        items = sortedItems
    }
}
