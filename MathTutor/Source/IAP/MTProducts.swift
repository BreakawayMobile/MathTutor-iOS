//
//  MTProducts.swift
//  MathTutor
//
//  Created by Joe Radjavitch on 5/1/15.
//  Copyright (c) 2015 Brightcove. All rights reserved.
//

import Foundation

// swiftlint:disable force_unwrapping

// Use enum as a simple namespace.  (It has no cases so you can't instantiate it.)
public enum MTProducts {
  
    /// Change this to whatever you set on iTunes connect
    fileprivate static let Prefix = Bundle.main.bundleIdentifier! + "."
  
    /// MARK: - Supported Product Identifiers
    public static let MonthlySubscription = Prefix + "monthlySubscription"
  
    // All of the products assembled into a set of product identifiers.
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [ MTProducts.MonthlySubscription ]
  
    /// Static instance of IAPHelper that for rage products.
    public static let store = IAPHelper(productIdentifiers: MTProducts.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

// swiftlint:enable force_unwrapping
