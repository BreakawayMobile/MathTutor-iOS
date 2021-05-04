//
//  MTCourseHeroCollectionView.swift
//  umc
//
//  Created by Joseph Radjavitch on 5/9/16.
//  Copyright © 2016 bcgs. All rights reserved.
//

// swiftlint:disable sorted_imports

import iCarousel
import BMMobilePackage
import UIKit

class MTCourseHeroView: UIView {
    
    @IBOutlet fileprivate weak var courseImage: UIImageView!
    
    static let reuseIdentifier = "MTCourseHeroView"
    static let defaultCellWidth: CGFloat = 308
    static let nibName: String = "MTCourseHeroView"
    
    lazy var imageUtils = BCGSImageUtilities.sharedInstance
    
    // MARK: BCGSVideoCellDelegate
    
    func cellReuseIdentifier() -> String {
        return MTCourseHeroView.reuseIdentifier
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        courseImage.layer.shadowColor = UMCConstants.shadowColor.cgColor
//        courseImage.layer.shadowOffset = UMCConstants.shadowOffset
//        courseImage.layer.shadowOpacity = UMCConstants.shadowOpacity
//        courseImage.layer.shadowRadius = UMCConstants.shadowRadius
//        franchiseImage.clipsToBounds = false
    }
    
    static func sizeForView() -> CGSize {
        let orientation = UIApplication.shared.statusBarOrientation
        var multiplier: CGFloat = 0.85
        
        if /*idiom == .pad &&*/ orientation.isLandscape {
            multiplier = UIDevice.isPad ? 0.625 : 0.475
        }
        
        let width = UIScreen.main.bounds.width * multiplier
        let height = width * 9 / 16
        
        return CGSize(width: width + 10, height: height)
    }
    
    func classObject() -> AnyClass! {
        return MTCourseHeroView.self
    }
    
    func configureWithCourse(_ course: BCGSPlayList) {
        let placeholder = UIImage.imageWithColor(UIColor.flatGray())
        
        if let thumb = course.thumbnailURL {
            if let url = URL(string: thumb) {
                courseImage.loadImageView(url, placeholderImage: placeholder)
            } else {
                courseImage.image = placeholder
            }
        } else {
            courseImage.image = placeholder
        }
    }
    
    func releaseResources() {
        
    }
}
// swiftlint:enable sorted_imports
