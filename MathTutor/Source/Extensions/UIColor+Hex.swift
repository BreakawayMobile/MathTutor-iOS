//
//  UIColor+Hex.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

private func colorComponent(fromByte: UInt8) -> CGFloat {
    return CGFloat(fromByte) / 255.0
}

private func colorByte(fromComponent: CGFloat) -> UInt8 {
    return UInt8(fromComponent * 255.0)
}

extension UIColor {

    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        func confineColorValue(value: Int) -> Int {
            var adjustedValue = value

            adjustedValue = value > 255 ? 255 : value
            adjustedValue = value < 0 ? 0 : value

            return adjustedValue
        }

        let red = confineColorValue(value: r)
        let green = confineColorValue(value: g)
        let blue = confineColorValue(value: b)

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }

    convenience init(rgbHex: Int, alpha: CGFloat = 1) {
        self.init(r: (rgbHex >> 16) & 0xFF, g: (rgbHex >> 8) & 0xFF, b: rgbHex & 0xFF, a: alpha)
    }

    // swiftlint:disable large_tuple
    var rgbaComponents: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)

        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    var hexString: String {
        let (r, g, b, _) = rgbaComponents
        return String(format: "#%02X%02X%02X", colorByte(fromComponent: r), colorByte(fromComponent: g), colorByte(fromComponent: b))
    }

    static func colorFromHex(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> UIColor {
        return UIColor(red: colorComponent(fromByte: red), green: colorComponent(fromByte: green), blue: colorComponent(fromByte: blue), alpha: colorComponent(fromByte: alpha))
    }
}
