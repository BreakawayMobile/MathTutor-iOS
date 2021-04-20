//
//  UICollectionReusableView+Reuse.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

extension UICollectionReusableView {

    static var reuseId: String {
        return String(describing: self)
    }
}
