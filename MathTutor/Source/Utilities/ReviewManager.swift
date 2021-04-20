//
//  ReviewManager.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 10/18/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import StoreKit

class ReviewManager: NSObject {

    // MARK: - Constants
    
    private enum Constants {
        static let kVideoViewsKey = "kVideoViewsKey"
        static let kFavoriteCountKey = "kFavoriteCountKey"
        static let kLastReviewRequestKey = "kLastReviewRequestKey"
        static let maxVideoViews: Int = 10
        static let maxFavorites = 5
        static let maxDateInterval: TimeInterval = 100 * 24 * 60
    }
    
    // MARK: - Public Properties

    open static let shared = ReviewManager()

    // MARK: - Private Properties
    
    fileprivate var videoViews: Int = 0
    fileprivate var favoriteCount: Int = 0
    fileprivate var lastReviewRequestDate: Date!
    
    // MARK: - Initialization

    override init() {
        super.init()
        
        if let value = UserDefaults.standard.object(forKey: Constants.kVideoViewsKey) as? Int {
            videoViews = value
        }
        
        if let value = UserDefaults.standard.object(forKey: Constants.kFavoriteCountKey) as? Int {
            favoriteCount = value
        }
        
        if let value = UserDefaults.standard.object(forKey: Constants.kLastReviewRequestKey) as? Date {
            lastReviewRequestDate = value
        }
    }
    
    // MARK: - Public Methods
    
    public func videoView() {
        NSLog("MTLog: videoView() called")
        videoViews += 1
        checkForReview()
    }
    
    public func favoriteAdded() {
        NSLog("MTLog: favoriteAdded() called")
        favoriteCount += 1
        checkForReview()
    }

    // MARK: - Private Methods

    fileprivate func checkForReview() {
        NSLog("MTLog: videoViews = \(videoViews)")
        NSLog("MTLog: favoriteCount = \(favoriteCount)")
        
        let countExceeded = videoViews >= Constants.maxVideoViews ||
                            favoriteCount >= Constants.maxFavorites
        
        let now = Date()
        let intervalString = lastReviewRequestDate == nil ? "nil" : "\(now.timeIntervalSince(lastReviewRequestDate))"
        NSLog("MTLog: dateInterval = \(intervalString)")

        let dateExceeded = lastReviewRequestDate == nil ||
                           now.timeIntervalSince(lastReviewRequestDate) >= Constants.maxDateInterval
        
        if countExceeded && dateExceeded {
            showReview()
            resetCounts()
        }
    }
    
    fileprivate func showReview() {
        NSLog("MTLog: showReview() called")
        if #available(iOS 10.3, *) {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    fileprivate func resetCounts() {
        videoViews = 0
        favoriteCount = 0
        lastReviewRequestDate = Date()
        saveCounts()
    }
    
    fileprivate func saveCounts() {
        UserDefaults.standard.set(videoViews, forKey: Constants.kVideoViewsKey)
        UserDefaults.standard.set(favoriteCount, forKey: Constants.kFavoriteCountKey)
        UserDefaults.standard.set(lastReviewRequestDate, forKey: Constants.kLastReviewRequestKey)
    }
}
