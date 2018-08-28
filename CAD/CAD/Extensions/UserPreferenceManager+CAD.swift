//
//  UserPreferenceManager+CAD.swift
//  CAD
//
//  Created by Christian  on 20/8/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

extension UserPreferenceManager {
    
    @discardableResult public func fetchUserPreferences() -> Promise<Void> {
        guard UserSession.current.isActive else { return Promise<Void>() }
        let appSpecificPreferences: [UserPreferenceKey] = [.recentCallsigns,
                                                            .recentOfficers]

        return fetchUserPreferences(application: User.applicationKey, preferenceKeys: appSpecificPreferences)
    }
}
