//
//  IAPHelper.swift
//  inappragedemo
//
//  Created by Ray Fix on 5/1/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import StoreKit

/// Notification that is generated when a product is purchased.
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
open class IAPHelper: NSObject {
  
    // MARK: - Private Properties
    
    // Used to keep track of the possible products and which ones have been purchased.
    fileprivate var productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    
    // Used by SKProductsRequestDelegate
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var completionHandler: RequestProductsCompletionHandler?
    fileprivate var purchaseTransactionCompletionHandler: TransactionCompletionHandler?
    fileprivate var restoreTransactionCompletionHandler: TransactionCompletionHandler?
    fileprivate var restoreTransactionsHandled: Bool?
    fileprivate var purchaseTransaction: SKPaymentTransaction?
    fileprivate var hasTrial: Bool?
    fileprivate let productRequestQueue = DispatchQueue(label: "com.nathtutordvd.mathtutor.products", attributes: [])
    
    // MARK: - User facing API
  
    /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
    public init(productIdentifiers: Set<ProductIdentifier>) {
        self.productIdentifiers = productIdentifiers
        
        for productIdentifier in productIdentifiers {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        
        super.init()
        SKPaymentQueue.default().add(self)
        self.hasTrial = true
    }
  
    /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
    open func requestProductsWithCompletionHandler(_ handler: @escaping RequestProductsCompletionHandler) {
        completionHandler = handler
        
        productRequestQueue.async { 
            self.productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers)
            self.productsRequest?.delegate = self
            self.productsRequest?.start()
        }
    }

    /// Initiates purchase of a product.
    open func purchaseProduct(_ product: SKProduct, handler: TransactionCompletionHandler!) {
        self.purchaseTransactionCompletionHandler = handler
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
  
    /// Given the product identifier, returns true if that product has been purchased.
    open func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    open func clearProductPurchases() {
        for productIdentifier in self.productIdentifiers {
            UserDefaults.standard.set(false, forKey: productIdentifier)
        }
        
        self.purchasedProductIdentifiers.removeAll()
    }
  
    /// If the state of whether purchases have been made is lost  (e.g. the
    /// user deletes and reinstalls the app) this will recover the purchases.
    open func restoreCompletedTransactions(_ handler: TransactionCompletionHandler!) {
        self.restoreTransactionsHandled = false
        self.restoreTransactionCompletionHandler = handler
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    open func trialAvailable() -> Bool {
        if let value = self.hasTrial {
            return value
        }
        
        return false
    }
    
    open func setTrialAvailable(_ value: Bool) {
        self.hasTrial = value
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        completionHandler?(true, nil, response.products)
        clearRequest()
        
//        let receipt = NSData(contentsOfURL: NSBundle.mainBundle().appStoreReceiptURL!)
//        let rcpString = String(data: receipt!, encoding: NSUTF8StringEncoding)
//        print("receipt = \(rcpString)")
        
        // debug printing
        for p in response.products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error)")
        completionHandler?(false, error as NSError?, [])
        clearRequest()
    }
    
    fileprivate func clearRequest() {
        productsRequest = nil
        completionHandler = nil
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    /// This is a function called by the payment queue, not to be called directly.
    /// For each transaction act accordingly, save in the purchased cache, issue notifications,
    /// mark the transaction as complete.
    // swiftlint:disable cyclomatic_complexity
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        self.restoreTransactionsHandled = true
        self.finishTransactions(transactions)
        
        if self.purchaseTransaction == nil {
            self.purchaseTransaction = getPurchaseTransaction(transactions)
            
//            if let transactionID = self.purchaseTransaction?.transactionIdentifier {
////                UMCAuthenticationStore.sharedInstance.setTransactionID(transactionID)
//            }
        }
        
        if let transaction = getLastTransaction(transactions) {
            switch transaction.transactionState {
            case .purchased:
//                if let tid = transaction.transactionIdentifier {
////                    UMCAuthenticationStore.sharedInstance.setTransactionID(tid)
//                }
                
                if let handler = self.purchaseTransactionCompletionHandler {
                    handler(nil, transaction)
                }

            case .failed:
                if let handler = self.purchaseTransactionCompletionHandler {
                    handler(nil, transaction)
                }
                if let handler = self.restoreTransactionCompletionHandler {
                    handler(nil, transaction)
                }

            case .restored:
                if let handler = self.restoreTransactionCompletionHandler {
                    handler(nil, transaction)
                }

            case .deferred:
                break
                
            case .purchasing:
                break
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreTransactionCompletionHandler?(error as NSError?, nil)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished")
        if self.restoreTransactionsHandled == false {
            restoreTransactionCompletionHandler?(nil, nil)
        }
    }
    
    fileprivate func finishTransactions(_ transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completeTransaction(transaction)

            case .failed:
                failedTransaction(transaction)

            case .restored:
                restoreTransaction(transaction)

            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    fileprivate func getLastTransaction(_ transactions: [SKPaymentTransaction]) -> SKPaymentTransaction? {
        if transactions.count == 1 {
            return transactions[0]
        }
        
        var retVal: SKPaymentTransaction = transactions[0]
        let range = 1...transactions.count - 1
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd @ HH:mm:ss:SSS"
        
        for index in range {
            
            if let value = transactions[index].transactionIdentifier {
                print("transaction identifier = \(value)")
            }
            
            print("transaction state = \(transactions[index].transactionState.rawValue)")
            
            if transactions[index].transactionState == .restored || transactions[index].transactionState == .purchased {
                if let value = transactions[index].transactionDate {
                    print("transaction date = \(formatter.string(from: value))")
                }
            }
            
            if let originalTransaction = transactions[index].original {
                if let value = originalTransaction.transactionIdentifier {
                    print("original transaction identifier = \(value)")
                }
                
                print("original transaction state = \(originalTransaction.transactionState.rawValue)")
                
                if originalTransaction.transactionState == .restored ||
                    originalTransaction.transactionState == .purchased {
                    if let value = originalTransaction.transactionDate {
                        print("original transaction date = \(formatter.string(from: value))")
                    }
                }
            }
            
            if let value = retVal.transactionDate {
                if transactions[index].transactionDate?.compare(value) == ComparisonResult.orderedDescending {
                    retVal = transactions[index]
                }
            }
        }
        
        return retVal
    }
    // swiftlint:enable cyclomatic_complexity

    fileprivate func getPurchaseTransaction(_ transactions: [SKPaymentTransaction]) -> SKPaymentTransaction? {
        var retVal: SKPaymentTransaction?
        
        for transaction in transactions {
            
            if transaction.transactionState == .purchased {
                retVal = transaction
            } else if transaction.original?.transactionState == .purchased {
                retVal = transaction.original
            }
        }
        
        return retVal
    }
    
    func getPurchaseTransactionID() -> String? {
        if self.purchaseTransaction != nil {
            return self.purchaseTransaction?.transactionIdentifier
        }
        
        return nil
    }
    
    fileprivate func completeTransaction(_ transaction: SKPaymentTransaction) {
        print("completeTransaction...")
        provideContentForProductIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func restoreTransaction(_ transaction: SKPaymentTransaction) {
        if let productIdentifier = transaction.original?.payment.productIdentifier {
            print("restoreTransaction... \(productIdentifier)")
            provideContentForProductIdentifier(productIdentifier)
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    // Helper: Saves the fact that the product has been purchased and posts a notification.
    fileprivate func provideContentForProductIdentifier(_ productIdentifier: String) {
        purchasedProductIdentifiers.insert(productIdentifier)
        UserDefaults.standard.set(true, forKey: productIdentifier)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelperProductPurchasedNotification),
                                        object: productIdentifier)
    }
    
    fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
        print("failedTransaction...")
        
        if let err = transaction.error as NSError? {
            if err.code != SKError.paymentCancelled.rawValue {
                if let value = transaction.error {
                    print("Transaction error: \(value.localizedDescription)")
                }
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
