//
//  MTCourseCollectionHeaderView.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/5/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import BMMobilePackage
import UIKit

class MTCourseCollectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "MTCourseCollectionHeaderView"
    static let nibName = "MTCourseCollectionHeaderView"
    
    static let cellHeight: CGFloat = 40.0
    
    var playlist: BCGSPlayList! {
        didSet {
            if playlist != nil {
                courseLabel.text = playlist.name
                
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.locale = Locale.current
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                if let dateString = playlist.dateCreated, dateString != "",
                   let dateCreated = formatter.date(from: dateString) {
                    let outFormatter = DateFormatter()
                    outFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    outFormatter.locale = Locale.current
                    outFormatter.dateStyle = .long
                    
                    dateLabel.text = " - " + outFormatter.string(from: dateCreated)
                    dateLabel.isHidden = false
                } else {
                    print("No date created")
                }
            }
        }
    }
    
    @IBOutlet weak var courseLabel: UILabel!    
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateLabel.isHidden = true
        
        if UIDevice.isPad {
            let fontIncrement: CGFloat = 2.0
            self.courseLabel.font = self.courseLabel.font.withSize(self.courseLabel.font.pointSize + fontIncrement)
            self.dateLabel.font = self.dateLabel.font.withSize(self.dateLabel.font.pointSize + fontIncrement)
        }
    }
}
