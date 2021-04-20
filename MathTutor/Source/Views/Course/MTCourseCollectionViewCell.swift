//
//  MTCourseCollectionViewCell.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/5/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import BMMobilePackage

class MTCourseCollectionViewCell: UICollectionViewCell,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegate,
                                  UICollectionViewDelegateFlowLayout {
    
    static let reuseIdentifier = "MTCourseCollectionViewCell"
    
    fileprivate var course: BCGSPlayList!
    fileprivate var parentVC: UIViewController!
    
    let lessonsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    static func cellHeight() -> CGFloat {
        return MTLessonCollectionViewCell.cellHeight()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.backgroundColor = UIColor.clear
        addSubview(lessonsCollectionView)
        
        lessonsCollectionView.dataSource = self
        lessonsCollectionView.delegate = self
        
        let lessonNib = UINib(nibName: MTLessonCollectionViewCell.nibName,
                              bundle: Bundle(for: MTLessonCollectionViewCell.self))

        lessonsCollectionView.register(lessonNib,
                                       forCellWithReuseIdentifier: MTLessonCollectionViewCell.reuseIdentifier)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|",
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: ["v0": lessonsCollectionView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|",
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: ["v0": lessonsCollectionView]))
    }
    
    func configure(with course: BCGSPlayList,
                   parentVC: UIViewController) {
        
        self.course = course
        self.parentVC = parentVC
        
        lessonsCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return course?.videos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = MTLessonCollectionViewCell.reuseIdentifier
        guard let cell = lessonsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? MTLessonCollectionViewCell else {
            fatalError("Expected a MTLessonCollectionViewCell object.")
        }
        
        guard let item = course.videos[indexPath.row] as? BCGSVideo else {
            fatalError("Expected a BCGSVideo object")
        }
                
        cell.configure(with: item,
                       indexPath: indexPath,
                       parentCollection: self.lessonsCollectionView,
                       parentViewController: self.parentVC)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: MTLessonCollectionViewCell.cellWidth(for: lessonsCollectionView),
                      height: frame.size.height)
    }
}
