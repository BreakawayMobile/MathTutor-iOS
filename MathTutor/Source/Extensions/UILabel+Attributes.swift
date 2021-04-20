//
//  UILabel+Attributes.swift
//  MathTutor
//
//  Created by Oscar Otero on 7/10/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

extension UILabel {

    func setLineHeight(lineHeight: CGFloat) {
        
        guard let stringValue = self.text else {
            return
        }
        let alignment: NSTextAlignment = self.textAlignment
        let attrString = NSMutableAttributedString(string: stringValue)
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lineHeight
        attrString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: stringValue.characters.count))
        self.attributedText = attrString
        self.textAlignment = alignment
        
    }
}

