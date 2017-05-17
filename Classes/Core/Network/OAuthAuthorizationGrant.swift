//
//  OAuthAuthorizationGrant.swift
//  MPOL
//
//  Created by Herli Halim on 17/5/17.
//
//

public enum OAuthAuthorizationGrant {
    
    /// Request token using username and password
    ///
    /// - Parameters:
    ///   - username: The username.
    ///   - password: The password.
    case credentials(username: String, password: String)
    
    /// A refresh token grant.
    ///
    /// - Parameters:
    ///   - refreshToken: The refresh token.
    case refreshToken(String)
        
    /// Returns the authorization grant's parameters.
    public var parameters: [String: String] {
        switch self {
        case .credentials(let username, let password):
            return [
                "grant_type": "password",
                "username": username,
                "password": password,
            ]
        case .refreshToken(let refreshToken):
            return [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
            ]
        }
    }
}
