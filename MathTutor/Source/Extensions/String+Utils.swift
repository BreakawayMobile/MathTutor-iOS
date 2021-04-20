//
//  String+Utils.swift
//  MathTutor
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

extension String {

    var length: Int {
        return characters.count
    }

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(start, offsetBy: r.upperBound - r.lowerBound)

        return self[Range(start ..< end)]
    }

    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return range(of: emailRegEx, options: .regularExpression, range: nil, locale: nil) != nil
    }

    func textHeight(forWidth width: CGFloat, font: UIFont) -> CGFloat {
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font], context: nil).height
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    static func formatTime(_ timeInterval: TimeInterval) -> String {
        let interval = timeInterval / 1000.0
        
        if interval == 0 {
            return "00:00"
        }
        let hours: Int = Int(floor(interval / 60.0 / 60.0))
        let minutes: Int = (NSInteger)(interval / 60.0) % 60
        let seconds = Int(interval) % 60
        
        var ret = ""
        if hours > 0 {
            ret = String(format: "%.1ld:%.2ld:%.2ld", Int(hours), Int(minutes), Int(seconds))
        }
        else if minutes < 10 {
            ret = String(format: "%.1ld:%.2ld", Int(minutes), Int(seconds))
        }
        else {
            ret = String(format: "%.2ld:%.2ld", Int(minutes), Int(seconds))
        }
        
        return ret
    }
    
    public enum TruncateMode {
        case Head, Middle, Tail
    }

    /// Truncates a string to a maximum length in grapheme clusters using the
    /// specified mode. If `addEllipsis` is `true`, the resulting string
    /// including the ellipsis will be no longer than `maxLength`.
    func truncateToLength(maxLength: Int, mode: TruncateMode = .Tail, addEllipsis: Bool = false) -> String {
        if maxLength <= 0 {
            return ""
        }
        switch mode {
        case .Head:
            guard let start = self.index(self.endIndex, offsetBy: -maxLength, limitedBy: self.startIndex) else {
                return self
            }
            if start == startIndex {
                // no truncation necessary
                return self
            }
            if addEllipsis {
                return "…\(self[self.index(after: start)..<endIndex])"
            }
            return self[start..<endIndex]
        case .Middle:
            let tailLength = maxLength / 2
            let headLength = maxLength - tailLength
            guard let headEnd = self.index(startIndex, offsetBy: headLength, limitedBy: endIndex) else {
                return self
            }
            if headEnd == endIndex {
                // no truncation necessary
                return self
            }
            guard let tailStart = self.index(endIndex, offsetBy: -tailLength, limitedBy: headEnd) else {
                return self
            }
            if tailStart == headEnd {
                // no truncation necessary
                return self
            }
            // always add the ellipsis for middle truncation
            return "\(self[startIndex..<self.index(before: headEnd)])…\(self[tailStart..<endIndex])"
        case .Tail:
            guard let end = self.index(startIndex, offsetBy: maxLength, limitedBy: endIndex) else {
                return self
            }
            
            if end == endIndex {
                // no truncation necessary
                return self
            }
            if addEllipsis {
                return "\(self[startIndex..<self.index(before: end)])…"
            }
            return self[startIndex..<end]
        }
    }
}
