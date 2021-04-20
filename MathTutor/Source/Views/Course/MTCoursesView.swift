//
//  MTCoursesView.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/5/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BMMobilePackage

class MTCoursesView: UIView,
                     UICollectionViewDataSource,
                     UICollectionViewDelegate,
                     UICollectionViewDelegateFlowLayout {

    static let nibName = "MTCoursesView"

    @IBOutlet weak var coursesLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var courses: [BCGSPlayList] = []
    fileprivate var parentVC: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MTCourseCollectionViewCell.self,
                                forCellWithReuseIdentifier: MTCourseCollectionViewCell.reuseIdentifier)
                
        collectionView.register(UINib(nibName: MTCourseCollectionHeaderView.nibName, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MTCourseCollectionHeaderView.reuseIdentifier)
    }
    
    override func layoutSubviews() {
        let newHeight: CGFloat = (MTCourseCollectionViewCell.cellHeight() + MTCourseCollectionHeaderView.cellHeight) * CGFloat(courses.count)
        self.collectionView.frame.size = CGSize(width: self.collectionView.frame.size.width,
                                                height: newHeight)
        
        self.collectionViewHeightConstraint.constant = newHeight
        
        self.frame.size = CGSize(width: self.frame.size.width,
                                 height: newHeight + 40.0)
    }
    
    func viewWillAppear() {
        self.collectionView.reloadData()
    }
    
    func sizeChanged() {
        self.collectionView.reloadData()
        self.sizeToFit()
    }
    
    func config(with courses: [BCGSPlayList], parentVC: UIViewController) {
        self.courses = courses
        self.parentVC = parentVC
        
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseId = MTCourseCollectionViewCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? MTCourseCollectionViewCell else {
            fatalError("Expected an MTCourseCollectionViewCell.reuseIdentifier object.")
        }

        let item = courses[indexPath.section]
        cell.configure(with: item, parentVC: self.parentVC)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let reuseId = MTCourseCollectionHeaderView.reuseIdentifier
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseId, for: indexPath) as? MTCourseCollectionHeaderView else {
                fatalError("Expected a MTCourseCollectionHeaderView object.")
            }
            
            let item = courses[indexPath.section]
            headerView.playlist = item
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.frame.size.width, height: MTCourseCollectionViewCell.cellHeight())
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.frame.size.width, height: MTCourseCollectionHeaderView.cellHeight)
    }
}
