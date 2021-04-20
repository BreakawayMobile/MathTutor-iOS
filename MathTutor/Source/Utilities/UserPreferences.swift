//
//  UserPreferences.swift
//  Lightbox
//
//  Created by Matthew Daigle on 6/6/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import Foundation

struct UserPreferences {

    enum Key: String {
        case email
        case token
    }

    static func bool(for key: Key) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    static func setBool(value: Bool, for key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func int(for key: Key) -> Int? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? Int
    }

    static func setInt(value: Int, for key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func string(for key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }

    static func setString(value: String, for key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func object(for key: Key) -> AnyObject? {
        return UserDefaults.standard.object(forKey: key.rawValue) as AnyObject?
    }

    static func setObject(value: NSObject, for key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func removeObject(for key: Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}

// MARK: - Key-specific convenience accessors

extension UserPreferences {

    private static func keyPrefix() -> String {
        return UserPreferences.email ?? ""
    }

    static var email: String? {
        get {
            return string(for: .email)
        }

        set {
            if let newValue = newValue {
                setString(value: newValue, for: .email)
            }
            else {
                removeObject(for: .email)
            }
        }
    }

    static var token: String? {
        get {
            return string(for: .token)
        }

        set {
            if let newValue = newValue {
                setString(value: newValue, for: .token)
            }
            else {
                removeObject(for: .token)
            }
        }
    }
}
