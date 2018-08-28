//
//  User+VersionAccessors.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

extension UserPreferenceKey {
    /// The appVersion at the last user login
    public static let highestUsedAppVersion = UserPreferenceKey("highestUsedAppVersion")
    
    /// The last terms and conditions version that was accepted
    public static let termsAndConditionsVersionAccepted = UserPreferenceKey("termsAndConditionsVersionAccepted")
    
    /// The last what's new screen version that was shown
    public static let whatsNewShownVersion = UserPreferenceKey("whatsNewShownVersion")
}

extension User {

    /// Convenience methods for common app settings
    public var highestUsedAppVersion: String? {
        get {
            return UserPreferenceManager.shared.preference(for: .highestUsedAppVersion)?.data
        }
        set {
            guard let value = newValue else { return }
            let preference = UserPreference(applicationName: User.appGroupKey, preferenceTypeKey: .highestUsedAppVersion, data: value )
            try? UserPreferenceManager.shared.updatePreference(preference)
        }
    }

    public var lastTermsAndConditionsVersionAccepted: String? {
        get {
            return UserPreferenceManager.shared.preference(for: .termsAndConditionsVersionAccepted)?.data
        }
        set {
            guard let value = newValue else { return }
            let preference = UserPreference(applicationName: User.appGroupKey, preferenceTypeKey: .termsAndConditionsVersionAccepted, data: value)
            try? UserPreferenceManager.shared.updatePreference(preference)
        }
    }

    public var lastWhatsNewShownVersion: String? {
        get {
            return UserPreferenceManager.shared.preference(for: .whatsNewShownVersion)?.data
        }
        set {
            guard let value = newValue else { return }
            let preference = UserPreference(applicationName: User.appGroupKey, preferenceTypeKey: .whatsNewShownVersion, data: value)
            try? UserPreferenceManager.shared.updatePreference(preference)
        }
    }
}
