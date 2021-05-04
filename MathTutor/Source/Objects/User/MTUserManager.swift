//
//  MTUserManager.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/11/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import BMMobilePackage
import StoreKit
import StorageKit
import UIKit

class MTUserManager: NSObject, SKRequestDelegate {
    
    let dataManager = BCGSDataManager.sharedInstance
    let receiptValidator = ReceiptValidator()
    let receiptRequest = SKReceiptRefreshRequest()
    let configController = ConfigController.sharedInstance

    public static let shared = MTUserManager()

    var products = [SKProduct]()
    
    override init() {
        super.init()
        
        MTProducts.store.requestProductsWithCompletionHandler { _, _, products in
            self.products = products
        }

        guard let udid = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError("Could not get UDID!!!")
        }
        
        let userName = "MT_" + udid
        let storage = dataManager.dataStorage()
        
        MTUser.initialize(userName, storage: storage) { (_) in
            
            let validationResult = self.receiptValidator.validateReceipt()
            
            switch validationResult {
            case .success(let parsedReceipt):
                if let iapReceipts = parsedReceipt.inAppPurchaseReceipts {
                    if self.validSubscription(iapReceipts) {
                        self.subscribe()
                        break
                    }
                }
                
                self.unsubscribe()
                
            case .error:
                MTUser.unsubscribed(storage: self.dataManager.dataStorage())
            }
        }
    }
    
    func subscribe() {
        MTUser.subscribed(storage: self.dataManager.dataStorage(), completion: { (updated) in
            if updated == true {
                MTProducts.store.restoreCompletedTransactions(nil)
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    fatalError("Exected an AppDelegate object")
                }
                
                appDelegate.subScriptionRestoredAlert()
            }
        })
    }
    
    func unsubscribe() {
        MTUser.unsubscribed(storage: self.dataManager.dataStorage(), completion: { (updated) in
            if updated == true {
                MTProducts.store.clearProductPurchases()
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    fatalError("Exected an AppDelegate object")
                }
                
                appDelegate.subScriptionAlert()
            }
        })
    }
    
    func validSubscription(_ receipts: [ParsedInAppPurchaseReceipt]) -> Bool {
        var validSubscription = false
        
        let now = Date()
        
        for receipt in receipts {
            if let subDate = receipt.subscriptionExpirationDate {
                if now < subDate {
                    validSubscription = true
                }
            }
        }
        
        return validSubscription
    }
    
    // MARK: - SKRequestDelegate
    
    func requestDidFinish(_ request: SKRequest) {
        let validationResult = receiptValidator.validateReceipt()
        
        switch validationResult {
        case .success:
            MTUser.subscribed(storage: self.dataManager.dataStorage())
            
        case .error:
            MTUser.unsubscribed(storage: self.dataManager.dataStorage())
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)        
        MTUser.unsubscribed(storage: self.dataManager.dataStorage())
    }
    
    // MARK: - Recently Watched
    
    public func recents(_ completion: (([BCGSVideo]) -> Void)!) {
        
        let storage = dataManager.dataStorage()
        
        PlayProgress.get(recents: storage) { (progressList) in
            var recentVideos: [BCGSVideo] = []
            
            for progressItem in progressList.prefix(GlobalConstants.Maximum.recentCount) {
                if let videoValue = Int64(progressItem.videoId) {
                    let videoId = NSNumber(value: videoValue)
                    if let video = self.dataManager.findVideo(for: videoId) {
                        recentVideos.append(video)
                    }
                }
            }
            
            completion?(recentVideos)
        }
    }
    
    // MARK: - Favorites
    
    public func favorites(_ completion: (([BCGSVideo]) -> Void)!) {
        
        let storage = dataManager.dataStorage()
        
        Favorite.get(recents: storage) { (favoriteList) in
            var recentVideos: [BCGSVideo] = []
            
            for favoriteItem in favoriteList {
                if let videoValue = Int64(favoriteItem.videoId) {
                    let videoId = NSNumber(value: videoValue)
                    if let video = self.dataManager.findVideo(for: videoId) {
                        recentVideos.append(video)
                    }
                }
            }
            
            completion?(recentVideos)
        }
    }
    
    // MARK: - Subscription
    
    func productWithIdentifier(_ identifier: String) -> SKProduct! {        
        let returnValue = self.products.first {
            let value = $0.productIdentifier
            let retVal = value == identifier
            return retVal
        }
        
        return returnValue
    }
    
    // swiftlint:disable cyclomatic_complexity
    public func purchaseSubscription() {
        guard let product = productWithIdentifier(MTProducts.MonthlySubscription) else {
            // fatalError("Could not find subscription product.")
            DispatchQueue.main.async {
                self.displayBasicAlert("Could not find any subscriptions.")
            }
            return
        }
        
        MTProducts.store.purchaseProduct(product) { (error, transaction) in
            if error == nil {
                if let state = transaction?.transactionState {
                    print("transactionState = \(state)")
                    switch state {
                    case .purchased:
                         MTUser.subscribed(storage: self.dataManager.dataStorage())
                    case .failed:
//                        self.showSpinner(false)
                        
                        if let code = transaction?.error?._code {
                            if code == SKError.paymentCancelled.rawValue {
//                                self.subscriptionAlreadyPurchased()
                                break
                            }
                        }
                        
                        let message = "SUBSCRIPTION_PURCHASE_FAILED".localized(self.configController.stringsFilename)
                        self.displayBasicAlert(message)
                    case .restored:
                        break
                    case .deferred:
                        break
                    case .purchasing:
                        break
                    }
                } else {
//                    self.showSpinner(false)
                    let message = "TRANSACTION_NOT_FOUND".localized(self.configController.stringsFilename)
                    self.displayBasicAlert(message)
                }
            } else {
//                self.showSpinner(false)
                if let message = error?.localizedDescription {
                    self.displayBasicAlert(message)
                }
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func displayBasicAlert(_ message: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Exected an AppDelegate object")
        }
        
        let alertController = UIAlertController(title: "",
                                                message: message,
                                                preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK".localized(self.configController.stringsFilename),
                                          style: .default,
                                          handler: nil)
        alertController.addAction(defaultAction)
        
        appDelegate.display(alert: alertController)        
    }
    
    func productPurchasePrompt() {
        let message = "SUBSCRIPTION_TEXT".localized(self.configController.stringsFilename)
        let alertController = UIAlertController(title: "",
                                                message: message,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK".localized(self.configController.stringsFilename),
                                     style: .default) { (_) in
            DispatchQueue.main.async {
                self.subscriptionInfoAlert()
            }
        }
        
        alertController.addAction(okAction)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Exected an AppDelegate object")
        }
        
        appDelegate.display(alert: alertController)
    }
    
    func subscriptionInfoAlert() {
        let message = "SUBSCRIPTION_BUY_MSG".localized(self.configController.stringsFilename)
        let alertController = UIAlertController(title: "",
                                                message: message,
                                                preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "YES".localized(self.configController.stringsFilename),
                                      style: .default) { (_) in
                                        MTUserManager.shared.purchaseSubscription()
        }
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "NO".localized(self.configController.stringsFilename),
                                     style: .cancel,
                                     handler: nil)
        alertController.addAction(noAction)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Exected an AppDelegate object")
        }
        
        appDelegate.display(alert: alertController)
    }
}
