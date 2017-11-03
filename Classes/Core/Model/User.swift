//
//  User.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

open class User: NSObject, NSSecureCoding, ModelVersionable {

    /// The username, fixed across apps
    public var username: String!

    /// Locally stored user app settings, keyed by specific mpol application
    public var appSettings: [String: LocalUserSettings] = [:] {
        didSet {
            UserSession.current.updateUser()
        }
    }

    /// Return the application specific key for app settings
    open var applicationKey: String {
        MPLRequiresConcreteImplementation()
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
    
    open static var supportsSecureCoding: Bool {
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
                // Error return failed init
                return nil
            }
        }

        // Load properties in expected order
        guard let username = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.username.rawValue) as String? else {
            return nil
        }
        guard let appSettings = aDecoder.decodeObject(of: NSDictionary.self, forKey: CodingKeys.appSettings.rawValue) as? [String: LocalUserSettings] else {
            return nil
        }
        self.username = username
        self.appSettings = appSettings

    }

    open func encode(with aCoder: NSCoder) {
        // Write the latest model version first, followed by current user properties
        aCoder.encode(User.modelVersion, forKey: CodingKeys.modelVersion.rawValue)
        aCoder.encode(username, forKey: CodingKeys.username.rawValue)
        aCoder.encode(appSettings, forKey: CodingKeys.appSettings.rawValue)
    }
    
    // MARK: - ModelVersionable
    public static var modelVersion: Int {
        return 2
    }

    public func performMigrationIfNeeded(from: Int, to: Int, decoder: NSCoder) throws -> Bool {
        // For previous versions, abort migration
        if from < 2 {
            throw ModelVersionableError.decodeError
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

// MARK: - Convenience methods for app settings
extension User {

    public var termsAndConditionsVersionAccepted: String? {
        get {
            return appSettings[applicationKey]?.termsAndConditionsVersionAccepted
        }
        set {
            appSettings[applicationKey]?.termsAndConditionsVersionAccepted = newValue
        }
    }

    public var whatsNewShownVersion: String? {
        get {
            return appSettings[applicationKey]?.whatsNewShownVersion
        }
        set {
            appSettings[applicationKey]?.whatsNewShownVersion = newValue
        }
    }
}
