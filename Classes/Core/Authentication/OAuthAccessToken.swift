//
//  OAuthAccessToken.swift
//  MPOL
//
//  Created by Herli Halim on 4/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Unbox

public class OAuthAccessToken: NSObject, Unboxable, NSSecureCoding {

    /// The acess token's type (e.g., Bearer).
    public let type: String

    /// The access token.
    public let accessToken: String
    
    /// The access token's expiration date.
    public let expiresAt: Date?
    
    /// The refresh token.
    public let refreshToken: String?
    
    /// The refresh token's expiration date.
    public let refreshTokenExpiresAt: Date?
    
    /// Initializes a new access token.
    ///
    /// - parameter accessToken: The access token.
    /// - parameter type: The access token's type.
    /// - parameter expiresAt: The access token's expiration date.
    /// - parameter refreshToken: The refresh token.
    ///
    /// - returns: A new OAuth token initialised with access token, type, expiration date and refresh token.
    public init(accessToken: String, type: String, expiresAt: Date? = nil, refreshToken: String? = nil, refreshTokenExpiresAt: Date? = nil) {
        self.accessToken = accessToken
        self.type = type
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
        self.refreshTokenExpiresAt = refreshTokenExpiresAt
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: - Unboxable
    
    private static let dateTransformer: EpochDateTransformer = EpochDateTransformer.shared
    
    public required convenience init(unboxer: Unboxer) throws {
        
        guard let accessToken: String = unboxer.unbox(key: "access_token"),
              let type: String = unboxer.unbox(key: "token_type") else {
            throw ParsingError.missingRequiredField
        }
        
        let refreshToken: String? = unboxer.unbox(key: "refresh_token")

        let expiresAt: Date? = unboxer.unbox(key: "access_token_expiry_time", formatter: OAuthAccessToken.dateTransformer)
        let refreshTokenExpiresAt: Date? = unboxer.unbox(key: "refresh_token_expiry_time", formatter: OAuthAccessToken.dateTransformer)
        
        self.init(accessToken: accessToken, type: type, expiresAt: expiresAt, refreshToken: refreshToken, refreshTokenExpiresAt: refreshTokenExpiresAt)
    }
    
    // MARK: - NSCoding
    
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let type  = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue) as String!,
            let accessToken = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.accessToken.rawValue) as String! else {
                return nil
        }
        
        let expiresAt = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.expiresAt.rawValue) as Date?
        let refreshToken = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.refreshToken.rawValue) as String?
        let refreshTokenExpiresAt = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.refreshTokenExpiresAt.rawValue) as Date?
        
        self.init(accessToken:              accessToken,
                  type:                     type,
                  expiresAt:                expiresAt,
                  refreshToken:             refreshToken,
                  refreshTokenExpiresAt:    refreshTokenExpiresAt)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
        aCoder.encode(accessToken, forKey: CodingKeys.accessToken.rawValue)
        if let expiresAt = expiresAt { aCoder.encode(expiresAt, forKey: CodingKeys.expiresAt.rawValue) }
        if let refreshToken = refreshToken { aCoder.encode(refreshToken, forKey: CodingKeys.refreshToken.rawValue) }
        if let refreshTokenExpiresAt = refreshTokenExpiresAt { aCoder.encode(refreshTokenExpiresAt, forKey: CodingKeys.refreshTokenExpiresAt.rawValue) }
    }

    private enum CodingKeys: String {
        case type = "type"
        case accessToken = "accessToken"
        case expiresAt = "expiresAt"
        case refreshToken = "refreshToken"
        case refreshTokenExpiresAt = "refreshTokenExpiresAt"
    }
    
}

// MARK: - Equatable

public func == (lhs: OAuthAccessToken, rhs: OAuthAccessToken) -> Bool {
    return lhs.accessToken == rhs.accessToken &&
        lhs.type == rhs.type &&
        lhs.expiresAt == rhs.expiresAt &&
        lhs.refreshToken == rhs.refreshToken &&
        lhs.refreshTokenExpiresAt == rhs.refreshTokenExpiresAt
}

