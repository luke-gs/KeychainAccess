//
//  User+VersionAccessors.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

extension User {

    /// Convenience methods for common app settings
    public var lastUsedAppVersion: String? {
        get {
            return appSettingValue(forKey: .lastUsedAppVersion) as? String
        }
        set {
            setAppSettingValue(newValue as AnyObject, forKey: .lastUsedAppVersion)
        }
    }

    public var lastTermsAndConditionsVersionAccepted: String? {
        get {
            return appSettingValue(forKey: .termsAndConditionsVersionAccepted) as? String
        }
        set {
            setAppSettingValue(newValue as AnyObject, forKey: .termsAndConditionsVersionAccepted)
        }
    }

    public var lastWhatsNewShownVersion: String? {
        get {
            return appSettingValue(forKey: .whatsNewShownVersion) as? String
        }
        set {
            setAppSettingValue(newValue as AnyObject, forKey: .whatsNewShownVersion)
        }
    }
}
