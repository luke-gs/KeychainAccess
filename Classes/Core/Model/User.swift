//
//  User.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

open class User: NSObject, NSSecureCoding, ModelVersionable {
    
    public let username: String
    
    public var termsAndConditionsVersionAccepted: String? = nil
    
    public init(username: String) {
        self.username = username
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let compared = object as? User else {
            return false
        }
        return username == compared.username && termsAndConditionsVersionAccepted == compared.termsAndConditionsVersionAccepted
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
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: CodingKeys.username.rawValue)
        aCoder.encode(termsAndConditionsVersionAccepted, forKey: CodingKeys.termsAndConditionsVersionAccepted.rawValue)
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
        
        case _modelVersion = "_modelVersion"
    }
}

/*
func ==(lhs: User, rhs: User) -> Bool {
    return lhs.username == rhs.username &&
        lhs.termsAndConditionsVersionAccepted == rhs.termsAndConditionsVersionAccepted
}
 */
