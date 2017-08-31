//
//  User.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol Using: class {
    var username: String { get }
    var termsAndConditionsVersionAccepted: String? { get }
    var whatsNewShownVersion: String? { get }
    var recentlyViewed: [MPOLKitEntity]? { get set }
    var recentlySearched: [Searchable]? { get set }
}

open class User: NSObject, NSSecureCoding, ModelVersionable, Using {

    public var username: String
    public var termsAndConditionsVersionAccepted: String?
    public var whatsNewShownVersion: String?
    public var recentlyViewed: [MPOLKitEntity]?
    public var recentlySearched: [Searchable]?

    public init(username: String) {
        self.username = username
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let compared = object as? User else {
            return false
        }
        return username == compared.username
            && termsAndConditionsVersionAccepted == compared.termsAndConditionsVersionAccepted
            && whatsNewShownVersion == compared.whatsNewShownVersion
    }
    
    // MARK: - NSSecureCoding
    
    open static var supportsSecureCoding: Bool {
        return true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let username = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.username.rawValue) as String? else {
            return nil
        }
        self.username = username
        self.termsAndConditionsVersionAccepted = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.termsAndConditionsVersionAccepted.rawValue) as String?
        self.whatsNewShownVersion = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.whatsNewShown.rawValue) as String?
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: CodingKeys.username.rawValue)
        aCoder.encode(termsAndConditionsVersionAccepted, forKey: CodingKeys.termsAndConditionsVersionAccepted.rawValue)
        aCoder.encode(whatsNewShownVersion, forKey: CodingKeys.whatsNewShown.rawValue)
        aCoder.encode(self.modelVersion, forKey: CodingKeys._modelVersion.rawValue)
    }
    
    // MARK: - ModelVersionable
    open var modelVersion: Int {
        return 1
    }
    
    // MARK: - CodingKeys
    private enum CodingKeys: String {
        case username = "username"
        case termsAndConditionsVersionAccepted = "termsAndConditionsVersionAccepted"
        case whatsNewShown = "whatsNewShown"

        case _modelVersion = "_modelVersion"
    }
}

/*
func ==(lhs: User, rhs: User) -> Bool {
    return lhs.username == rhs.username &&
        lhs.termsAndConditionsVersionAccepted == rhs.termsAndConditionsVersionAccepted
}
 */
