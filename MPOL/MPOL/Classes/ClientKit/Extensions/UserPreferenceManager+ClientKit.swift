//
//  UserPreferenceManager+ClientKit.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import PromiseKit

extension UserPreferenceManager {
    
    /// Fetch user preferences that are used in both applications
    @discardableResult public func fetchSharedUserPreferences() -> Promise<Void> {
        guard UserSession.current.isActive else { return Promise<Void>() }
        let sharedPreferences: [UserPreferenceKey] = [.signaturePreference,
                                                      .highestUsedAppVersion,
                                                      .termsAndConditionsVersionAccepted,
                                                      .whatsNewShownVersion,
                                                      .recentCallsigns,
                                                      .recentOfficers]
        return fetchUserPreferences(application: User.appGroupKey, preferenceKeys: sharedPreferences)
    }
}
