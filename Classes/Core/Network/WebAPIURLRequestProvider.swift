//
//  WebAPIURLRequestProvider.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//
//

import UIKit

public protocol WebAPIURLRequestProvider {
    
    associatedtype Configuration: APIURLRequestProviderConfigurable
    
    // MARK: - Authentications
    
    /// Create a access token request.
    ///
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A URLRequest to request for access token.
    func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> URLRequest
    
    /// Create a credentials validation using basic authentatication request.
    ///
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    /// - Returns: A URLRequest to check validity of the credentials.
    func basicAuthLoginRequestFor(username: String, password: String) -> URLRequest
    
    /// Create a person search request.
    ///
    /// - Parameters:
    ///   - source: The source to search it from
    ///   - parameters: The search criteria
    /// - Returns: A URLRequest to search the person.
    func searchPerson(from source: Configuration.Source, with parameters: Configuration.PersonSearchParametersType) -> URLRequest
    
}
