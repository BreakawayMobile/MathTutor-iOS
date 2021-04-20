//
//  MTFeaturedHeroView.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/3/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BGSMobilePackage
import iCarousel

class MTFeaturedHeroView: UIView,
                          iCarouselDataSource,
                          iCarouselDelegate {

    static let nibName = "MTFeaturedHeroView"
    
    let kAutoScrollTimeout = 6.0
    
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var currentCourseLabel: UILabel!
    @IBOutlet weak var coursePageControl: UIPageControl!
    @IBOutlet weak var carouselHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var courseTitleLabel: UILabel!
    @IBOutlet weak var courseTitleWidthConstraint: NSLayoutConstraint!
    
    fileprivate var courses: [BCGSPlayList] = []
    fileprivate var timer: Timer!
    fileprivate var tempView: MTCourseHeroView!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()

        carousel.dataSource = self
        carousel.delegate = self
        carousel.type = .linear
        
//        coursePageControl.activeImage = UIImage(named: pageSelectedImage)
//        coursePageControl.inactiveImage = UIImage(named: pageImage)

        tempView = UIView.fromNib(nibName: MTCourseHeroView.nibName) as? MTCourseHeroView
        tempView.frame.size = MTCourseHeroView.sizeForView()
        carouselHeightConstraint.constant = tempView.frame.size.height
        labelWidthConstraint.constant = tempView.frame.size.width - 10
        courseTitleWidthConstraint.constant = labelWidthConstraint.constant
    }
    
    func setCourseItems(_ items: [BCGSPlayList]) {
        self.courses = items
        coursePageControl.numberOfPages = courses.count
        carousel.reloadData()
        setCourseText()
    }
    
    func setCourseText() {
        let item = courses[carousel.currentItemIndex]
        self.courseTitleLabel.text = item.name
        self.currentCourseLabel.text = item.shortDescription
        
//        let nameString = item.name + " - "
//        let range = (tempString as NSString).range(of: nameString)
//        let labelString = NSMutableAttributedString(string: tempString)
//        let boldFont = UIFont(name: Style.Font.Gotham.bold.rawValue,
//                              size: currentCourseLabel.font.pointSize)
//            
//        let boldAttribute = [NSFontAttributeName: boldFont as Any]
//        labelString.addAttributes(boldAttribute, range: range)
//        
//        
//                
//        let tempString = nameString + aescription
//        let endRangeStart = range.length + 1
//        let endRangeLength = tempString.length - endRangeStart
//        let endRange = NSMakeRange(endRangeStart, endRangeLength)
//        let regularFont = UIFont(name: Style.Font.Gotham.book.rawValue,
//                                 size: currentCourseLabel.font.pointSize)
//        let regularAttribute = [NSFontAttributeName: regularFont as Any]
//        labelString.addAttributes(regularAttribute, range: endRange)
//
//        currentCourseLabel.attributedText = labelString
    }
    
    func viewWillDisappear() {
        self.stopRotatingViews()
    }
    
    func viewWillAppear() {
        carousel.reloadData()
        self.startRotatingViews()
    }
    
    func sizeChanged() {
        carousel.reloadData()
        self.sizeToFit()
    }
    
    // MARK: - iCarouselDataSource
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var cView: MTCourseHeroView! = nil
        
        let course = courses[index]
        if let view = view as? MTCourseHeroView {
            cView = view
        } else {
            cView = UIView.fromNib(nibName: MTCourseHeroView.nibName) as? MTCourseHeroView
            cView.backgroundColor = UIColor.clear
        }
        
        cView.frame.size = MTCourseHeroView.sizeForView()
        cView.configureWithCourse(course)
        
        return cView
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return self.courses.count 
    }
    
    // MARK: - iCarouselDelegate
    
    func carousel(_ carousel: iCarousel,
                  valueFor option: iCarouselOption,
                  withDefault value: CGFloat) -> CGFloat {
        
        if option == .wrap {
            return 1
        }
        
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let playlist = self.courses[index]
        Controllers.push(with: String(playlist.playlistID.int64Value),
                         courseTitle: playlist.name)
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        coursePageControl.currentPage = carousel.currentItemIndex
        setCourseText()
    }

    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = MTFeaturedHeroCollectionViewCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? MTFeaturedHeroCollectionViewCell else {
            fatalError("Expected an MTFeaturedHeroCollectionViewCell object")
        }
        
        let item = courses[indexPath.item]
        let placeholder = UIImage.imageWithColor(UIColor.flatGray())
        
        if let thumb = item.thumbnailURL {
            if let url = URL(string: thumb) {
                cell.imageView.loadImageView(url, placeholderImage: placeholder)
            } else {
                cell.imageView.image = placeholder
            }
        } else {
            cell.imageView.image = placeholder
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // This is Just for example , for the scenario Step-I -> 1
        let yourWidthOfLabel = collectionView.frame.size.width * 0.8
        let expectedHeight = yourWidthOfLabel * 9 / 16
        
        return CGSize(width: yourWidthOfLabel, height: expectedHeight)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: View Rotation
    
    func startRotatingViews() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(kAutoScrollTimeout),
                                         target: self,
                                         selector: #selector(MTFeaturedHeroView.updateCell),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func stopRotatingViews() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func updateCell() {
        weak var weakSelf = self
        if Thread.current != Thread.main {
            DispatchQueue.main.async(execute: { () -> Void in
                weakSelf?.updateCell()
            })
        }
        
        var index = 0
        if carousel.currentItemIndex != courses.count - 1 {
            index = carousel.currentItemIndex + 1
        }
        
        carousel.scrollToItem(at: index, animated: true)
    }
}
