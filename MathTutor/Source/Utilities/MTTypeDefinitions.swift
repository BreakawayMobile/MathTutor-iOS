//
//  MTTypeDefinitions.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/16/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import Foundation
import StoreKit

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (_ success: Bool, _ error: NSError?, _ products: [SKProduct]) -> Void

public typealias TransactionCompletionHandler = (_ error: NSError?, _ transaction: SKPaymentTransaction?) -> Void
