//
//  WebAPIProtocol.swift
//  Pods
//
//  Created by Herli Halim on 18/5/17.
//
//

import UIKit

public protocol WebAPIURLRequestProvider {
    
    // MARK: - Authentications
    
    /// Create a access token request.
    ///
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A URLRequest to request for access token.
    func accessTokenRequest(grant: OAuthAuthorizationGrant) -> URLRequest
    
    /// Create a credentials validation using basic authentatication request.
    ///
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    /// - Returns: A URLRequest to check validity of the credentials.
    func basicAuthenticationLogin(using username: String, password: String) -> URLRequest
    
    
    // MARK: - Entity Search
}
