//
//  ReceiptFetcher.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/16/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit
import StoreKit

class ReceiptFetcher: NSObject, SKRequestDelegate {
    let receiptRefreshRequest = SKReceiptRefreshRequest()
    
    override init() {
        super.init()
        receiptRefreshRequest.delegate = self
    }
    
    func fetchReceipt() {
        let receiptUrl = Bundle.main.appStoreReceiptURL
        
        do {
            if let receiptFound = try receiptUrl?.checkResourceIsReachable() {
                if (receiptFound == false) {
                    receiptRefreshRequest.start()
                }
            }
        } catch {
            print("Could not check for receipt presence for some reason... \(error.localizedDescription)")
        }
    }
    
    // MARK: - SKRequestDelegate
    
    func requestDidFinish(_ request: SKRequest) {
        print("The request finished successfully")
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Something went wrong: \(error.localizedDescription)")
    }
}
