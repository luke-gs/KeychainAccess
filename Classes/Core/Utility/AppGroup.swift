//
//  AppGroup.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class AppGroup {

    /// The info plist key for the app group ID
    public static let infoAppGroupIdKey = "APP_GROUP_ID"

    /// Return the app group id, or nil if not set
    public static func appGroupId() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: AppGroup.infoAppGroupIdKey) as? String
    }

    /// Return the app group user defaults, or standard user defaults if not set
    public static func appUserDefaults() -> UserDefaults {
        if let appGroupId = appGroupId(), let userDefaults = UserDefaults(suiteName: appGroupId) {
            return userDefaults
        }
        // Fallback on standard
        return UserDefaults.standard
    }

    public static func appBaseFilePath() -> URL {
        // Use the shared app group directory if configured
        if let appGroup = AppGroup.appGroupId(),
            let appGroupPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            return appGroupPath
        }
        // Fallback on documents directory
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
