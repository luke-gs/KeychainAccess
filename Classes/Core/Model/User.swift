//
//  User.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


open class User: NSObject, NSSecureCoding, ModelVersionable {

    // The application specific key for app settings. Required to be set if accessing appSettings
    open static var applicationKey: String!

    /// The username, fixed across apps and required after init completes
    public var username: String!

    /// Locally stored user app settings, keyed by specific mpol application
    public var appSettings: [String: [AppSettingKey: AnyObject]] = [:] {
        didSet {
            UserSession.current.updateUser()
        }
    }

    public init(username: String) {
        self.username = username
    }

    override open func isEqual(_ object: Any?) -> Bool {
        guard let compared = object as? User else {
            return false
        }
        return username == compared.username &&
            NSDictionary(dictionary: appSettings).isEqual(to: compared.appSettings)
    }
    
    // MARK: - NSSecureCoding
    
    open class var supportsSecureCoding: Bool {
        return true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()

        // Check model version and do migration here if neccessary
        let lastModelVersion = aDecoder.decodeInteger(forKey: CodingKeys.modelVersion.rawValue)
        if lastModelVersion != User.modelVersion {
            do {
                if try performMigrationIfNeeded(from: lastModelVersion, to: User.modelVersion, decoder: aDecoder) {
                    // Migration performed, return
                    return
                }
            } catch {
                // Failed, so return nil from init
                print("Failed to migrate old User object")
                return nil
            }
        }

        // Load properties in expected order
        guard let username = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.username.rawValue) as String? else {
            return nil
        }
        self.username = username

        guard let appSettings = aDecoder.decodeObject(of: NSDictionary.self, forKey: CodingKeys.appSettings.rawValue) as? [String: [String: AnyObject]] else {
            return nil
        }
        // Convert app settings back to custom type
        let settings = Dictionary(uniqueKeysWithValues: appSettings.map { (appKey, settings) in (appKey, Dictionary(uniqueKeysWithValues: settings.map { (settingKey, value) in (AppSettingKey(rawValue: settingKey), value) })) })
        self.appSettings = settings
    }

    open func encode(with aCoder: NSCoder) {
        // Write the latest model version first, followed by current user properties
        aCoder.encode(User.modelVersion, forKey: CodingKeys.modelVersion.rawValue)
        aCoder.encode(username, forKey: CodingKeys.username.rawValue)

        // Convert app setting key before encoding, otherwise struct would need to implement NSObject, NSSecureCoding, NSCopying, etc
        let settings = Dictionary(uniqueKeysWithValues: appSettings.map { (appKey, settings) in (appKey, Dictionary(uniqueKeysWithValues: settings.map { (settingKey, value) in (settingKey.rawValue, value) })) })
        aCoder.encode(settings, forKey: CodingKeys.appSettings.rawValue)
    }
    
    // MARK: - App Settings
    public func appSettingValue(forKey settingKey: AppSettingKey) -> AnyObject? {
        return appSettings[User.applicationKey]?[settingKey]
    }

    public func setAppSettingValue(_ newValue: AnyObject?, forKey settingKey: AppSettingKey) {
        // Update setting and trigger didSet on appSettings
        var settings = appSettings[User.applicationKey] ?? [:]
        settings[settingKey] = newValue
        appSettings[User.applicationKey] = settings
    }

    // MARK: - ModelVersionable
    public static var modelVersion: Int {
        return 2
    }

    public func performMigrationIfNeeded(from: Int, to: Int, decoder: NSCoder) throws -> Bool {
        // For previous versions, abort migration
        if from < 2 {
            throw ModelVersionableError.migrationNotsupported
        }
        return false
    }

    // MARK: - CodingKeys
    private enum CodingKeys: String {
        case modelVersion = "modelVersion"
        case username = "username"
        case appSettings = "appSettings"
    }
}

// MARK: - Convenience methods for common app settings
extension User {

    public func areTermsAndConditionsAccepted(version: String) -> Bool {
        // Return true if any mpol based app has accepted the requested version
        for (_, settings) in appSettings {
            if let acceptedVersion = settings[.termsAndConditionsVersionAccepted] as? String {
                if acceptedVersion == version {
                    return true
                }
            }
        }
        return false
    }

    public var termsAndConditionsVersionAccepted: String? {
        get {
            return appSettingValue(forKey: .termsAndConditionsVersionAccepted) as? String
        }
        set {
            setAppSettingValue(newValue as AnyObject, forKey: .termsAndConditionsVersionAccepted)
        }
    }

    public var whatsNewShownVersion: String? {
        get {
            return appSettingValue(forKey: .whatsNewShownVersion) as? String
        }
        set {
            setAppSettingValue(newValue as AnyObject, forKey: .whatsNewShownVersion)
        }
    }

}
