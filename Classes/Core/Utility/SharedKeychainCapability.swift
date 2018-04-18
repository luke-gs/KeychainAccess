//
//  SharedKeychainCapability.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import KeychainAccess

public struct SharedKeychainCapability {

    public static let sharedKeychainAccessGroupKey = "PSSharedKeychainAccessGroup"

    private static var _defaultSharedKeychainAccessGroup: String? = {
        return Bundle.main.object(forInfoDictionaryKey: SharedKeychainCapability.sharedKeychainAccessGroupKey) as? String
    }()

    public static var defaultSharedKeychainAccessGroup: String {
        assert(_defaultSharedKeychainAccessGroup != nil, "PSSharedKeychainAccessGroup is not declared in the Info.plist")
        return _defaultSharedKeychainAccessGroup!
    }

    public static var defaultKeychain: Keychain = {
        let accessGroup: String
        // Create a mock keychain if testing.
        if TestingDirective.isTesting {
            accessGroup = "pscore.testing.keychain"
        } else {
            accessGroup = SharedKeychainCapability.defaultSharedKeychainAccessGroup
        }
        return Keychain(accessGroup: accessGroup)
    }()
}
