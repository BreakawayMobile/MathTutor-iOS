//
//  MTSearchCollectionReusableView.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/9/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import BGSMobilePackage
import UIKit

class MTSearchCollectionReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = "MTSearchCollectionReusableView"
    static let nibName = "MTSearchCollectionReusableView"
    
    static let cellHeight: CGFloat = 40.0
    
    var playlist: BCGSPlayList!
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        courseLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(MTSearchCollectionReusableView.tapFunction(_:)))
        
        courseLabel.addGestureRecognizer(tap)
        
        if UIDevice.isPad {
            let fontIncrement: CGFloat = 2.0
            self.courseLabel.font = self.courseLabel.font.withSize(self.courseLabel.font.pointSize + fontIncrement)
            self.titleLabel.font = self.titleLabel.font.withSize(self.titleLabel.font.pointSize + fontIncrement)
        }
    }
    
    func tapFunction(_ sender: UITapGestureRecognizer) {
        print("tap working")
        Controllers.push(with: String(self.playlist.playlistID.int64Value),
                         courseTitle: playlist.name)
    }
}
