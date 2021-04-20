//
//  TallBar.swift
//  MathTutor
//
//  Created by Joseph Radjavitch on 8/7/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

class TallBar: UINavigationBar {
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height += 20
        return size
    }    
}
