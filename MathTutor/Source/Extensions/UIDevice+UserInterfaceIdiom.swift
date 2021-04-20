//
//  UIDevice+UserInterfaceIdiom.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

extension UIDevice {
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}
