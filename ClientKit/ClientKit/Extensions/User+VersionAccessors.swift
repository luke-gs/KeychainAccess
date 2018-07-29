//
//  User+VersionAccessors.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

// MARK: - Convenience methods for common app settings
extension User {

    public var lastUsedAppVersion: String? {
        get {
            return appGroupSettingValue(forKey: .lastUsedAppVersion) as? String
        }
        set {
            setAppGroupSettingValue(newValue as AnyObject, forKey: .lastUsedAppVersion)
        }
    }

    public var lastTermsAndConditionsVersionAccepted: String? {
        get {
            return appGroupSettingValue(forKey: .termsAndConditionsVersionAccepted) as? String
        }
        set {
            setAppGroupSettingValue(newValue as AnyObject, forKey: .termsAndConditionsVersionAccepted)
        }
    }

    public var lastWhatsNewShownVersion: String? {
        get {
            return appGroupSettingValue(forKey: .whatsNewShownVersion) as? String
        }
        set {
            setAppGroupSettingValue(newValue as AnyObject, forKey: .whatsNewShownVersion)
        }
    }

}
