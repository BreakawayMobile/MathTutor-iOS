//
//  MTCourseCenteredCollectionHeaderView.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/5/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class MTCourseCenteredCollectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "MTCourseCenteredCollectionHeaderView"
    static let nibName = "MTCourseCenteredCollectionHeaderView"
    
    static let cellHeight: CGFloat = 50.0
    
    @IBOutlet weak var courseLabel: UILabel!
}
