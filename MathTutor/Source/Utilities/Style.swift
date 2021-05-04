//
//  Style.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

struct Style {

    struct Color {
        static let successGreen = UIColor(rgbHex: 0x63B829)
        static let failureRed = UIColor(rgbHex: 0x9C2529)
        static let backgroundGray = UIColor(rgbHex: 0x252525)
        static let separatorGray = UIColor(rgbHex: 0x3A3A3A)
        static let darkGrayText = UIColor(rgbHex: 0x282828)
        static let almostWhite = UIColor(rgbHex: 0xEEEEEE)
        
        // Colors as defined in designs
        static let dandelion = UIColor(rgbHex: 0xFFD60F)
        static let sunflowerYellow = UIColor(rgbHex: 0xFFD500)
        static let lipstick = UIColor(rgbHex: 0xE73339)
        static let rouge = UIColor(rgbHex: 0x9C2529)
        static let darkSkyBlue = UIColor(rgbHex: 0x46BDE4)
        static let veryLightBlue = UIColor(rgbHex: 0xECF9FF)
        
        static let lightGrey = UIColor(rgbHex: 0xC3C3C3)
        static let warmGrey = UIColor(rgbHex: 0x9E9E9E)
        static let warmGreyTwo = UIColor(rgbHex: 0x979797)
        static let greyishBrown = UIColor(rgbHex: 0x404040)

        static let black = UIColor(rgbHex: 0x333333)
        static let blackTwo = UIColor(rgbHex: 0x000000)
        static let blackThree = UIColor(rgbHex: 0x212121)
        static let blackFour = UIColor(rgbHex: 0x191919)
        
        static let umcBlue = UIColor(rgbHex: 0x005175)
        static let darkBlue = UIColor(rgbHex: 0x00315C)

        static let menu1Blue = UIColor(rgbHex: 0x014F7D)
        static let menu2Blue = UIColor(rgbHex: 0x003452)
        static let menu3Blue = UIColor(rgbHex: 0x002131)
        
        static let grad1Green = UIColor(rgbHex: 0x2FB155)
        static let grad2Green = UIColor(rgbHex: 0x005900)
        
        static let grad1Blue = UIColor(rgbHex: 0x46B7DA)
        static let grad2Blue = UIColor(rgbHex: 0x00669B)
    }

    struct Font {

        enum Family: String {
            case gothamRounded    = "GothamRounded-"
            case gtWalsheim       = "GTWalsheim"
        }

        // The style suffix that goes after the font family name.
        // Note that not all fonts provide all of these style variants.
        enum Style: String {
            case black     = "Black"
            case bold      = "Bold"
            case book      = "Book"
            case light     = "Light"
            case medium    = "Medium"
        }
        
        enum Gotham: String {
            case xLightItalic = "GothamHTF-XLightItalic"
            case mediumCondensed = "GothamHTF-MediumCondensed"
            case boldItalic = "GothamHTF-BoldItalic"
            case boldCondensed = "GothamHTF-BoldCondensed"
            case thinItalic = "GothamHTF-ThinItalic"
            case light = "GothamHTF-Light"
            case lightItalic = "GothamHTF-LightItalic"
            case bold = "GothamHTF-Bold"
            case xLight = "GothamHTF-XLight"
            case blackItalic = "GothamHTF-BlackItalic"
            case book = "GothamHTF-Book"
            case thin = "GothamHTF-Thin"
            case medium = "GothamHTF-Medium"
            case lightCondensed = "GothamHTF-LightCondensed"
            case ultra = "GothamHTF-Ultra"
            case ultraItalic = "GothamHTF-UltraItalic"
            case black = "GothamHTF-Black"
        }

        static func fontName(for family: Family, style: Style, italic: Bool = false) -> String {
            let name = family.rawValue + style.rawValue
            return italic ? name + "Italic" : name
        }

        static func with(family: Family, style: Style, italic: Bool = false, size: CGFloat) -> UIFont {
            let name = fontName(for: family, style: style, italic: italic)
            
            if let font = UIFont(name: name, size: size) {
                return font
            }
            
            return UIFont.systemFont(ofSize: size)
        }

        // iOS default is San Francisco Semibold 17pt
        static let navigationBarTitleFont = Font.with(family: .gothamRounded, style: .medium, size: 17)

        // iOS default is San Francisco Regular 17pt
        static let barButtonItemTitleFont = UIFont(name: Gotham.book.rawValue, size: 17)
    }

    static func configureAppearance() {
        configureAppearance(proxy: UINavigationBar.appearance())
        configureAppearance(proxy: UIBarButtonItem.appearance())

        // MARK: Searchbar appearance
        let font = Font.with(family: .gothamRounded, style: .medium, size: UIDevice.isPad ? 20 : 17)
        let searchTextField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchTextField.font = font
        searchTextField.textColor = UIColor.black
    }

    fileprivate static func configureAppearance(proxy: UINavigationBar) {
        let attributes = [NSAttributedString.Key.font.rawValue: Font.navigationBarTitleFont,
                          NSAttributedString.Key.foregroundColor.rawValue: Style.Color.almostWhite]
        
        proxy.barTintColor = Style.Color.umcBlue
        proxy.tintColor = .white
        proxy.isTranslucent = false
        proxy.titleTextAttributes = String.convertToOptionalNSAttributedStringKeyDictionary(attributes)
    }

    fileprivate static func configureAppearance(proxy: UIBarButtonItem) {
        let fontKey = String.convertFromNSAttributedStringKey(NSAttributedString.Key.font)
        let fgColorKey = String.convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)
        let attrs = [fontKey: Font.barButtonItemTitleFont as Any,
                     fgColorKey: UIColor.white]
        let attributesKey = String.convertToOptionalNSAttributedStringKeyDictionary(attrs)
        
        proxy.setTitleTextAttributes(attributesKey, for: UIControl.State())
    }
}
