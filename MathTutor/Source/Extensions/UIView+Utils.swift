//
//  UIView+Utils.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

extension UIView {

    // MARK: - IBInspectable Properties

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable var shadowColor: UIColor {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            else {
                return UIColor.black
            }
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }

    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable var shadowOffsetX: CGFloat {
        get {
            return layer.shadowOffset.width
        }
        set {
            layer.shadowOffset.width = newValue
        }
    }

    @IBInspectable var shadowOffsetY: CGFloat {
        get {
            return layer.shadowOffset.height
        }
        set {
            layer.shadowOffset.height = newValue
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let c = layer.borderColor {
                return UIColor(cgColor: c)
            }
            else {
                return nil
            }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    // MARK: - UI Configuration

    func addShadow(color: CGColor = UIColor(rgbHex: 0xCCCCCC, alpha: 0.5).cgColor) {
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 2.0
        layer.shadowColor = color
    }

    func removeShadow() {
        layer.shadowOpacity = 0.0
    }

    func addTopLine(color: UIColor, height: CGFloat = (1/UIScreen.main.scale)) {
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: height))
        topLine.backgroundColor = color
        topLine.translatesAutoresizingMaskIntoConstraints = false

        addSubview(topLine)

        addConstraints([
            NSLayoutConstraint(item: topLine,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: topLine,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .right,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: topLine,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: topLine,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: height)
            ])
    }

    func addBottomLine(color: UIColor, height: CGFloat = (1/UIScreen.main.scale)) {
        let bottomLine = UIView(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: height))
        bottomLine.backgroundColor = color
        bottomLine.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bottomLine)

        addConstraints([
            NSLayoutConstraint(item: bottomLine,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: bottomLine,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .right,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: bottomLine,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: bottomLine,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: height)
            ])
    }

    func addTopBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: thickness)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - thickness,
                              y: 0,
                              width: thickness,
                              height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0,
                              y: self.frame.size.height - thickness,
                              width: self.frame.size.width,
                              height: thickness)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func roundCorners(radius: CGFloat = 5.0) {
        layer.cornerRadius = radius
    }

    class func fromNib<T: UIView>(nibName: String? = nil) -> T? {
        let name = nibName ?? String(describing: self)
        guard let v  = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.last as? T else {
            fatalError("Cannot load from nib \(name)")
        }
        return v
    }

    // add another view keeping resizing mask sizes
    func add(to view: UIView) {
        view.addSubview(self)

        frame = view.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func currentFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }

        for view in subviews {
            if let view = view.currentFirstResponder() {
                return view
            }
        }

        return nil
    }

    func recursivelyFindSubview(condition: (UIView) -> Bool) -> UIView? {
        if condition(self) {
            return self
        }

        for view in subviews {
            if let found = view.recursivelyFindSubview(condition: condition) {
                return found
            }
        }

        return nil
    }
    
    func centerInSuperview() {
        self.centerHorizontallyInSuperview()
        self.centerVerticallyInSuperview()
    }
    
    func centerHorizontallyInSuperview(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self,
                                                       attribute: .centerX,
                                                       relatedBy: .equal,
                                                       toItem: self.superview,
                                                       attribute: .centerX,
                                                       multiplier: 1,
                                                       constant: 0)
        self.superview?.addConstraint(c)
    }
    
    func centerVerticallyInSuperview(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: self.superview,
                                                       attribute: .centerY,
                                                       multiplier: 1,
                                                       constant: 0)
        self.superview?.addConstraint(c)
    }

}
