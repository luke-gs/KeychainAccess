//
//  WebAPIProtocol.swift
//  MPOLKit
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
    
    // FIXME: Please.. Not even sure what this is
    
    // MARK: - Entity Search
    
    func searchPerson(with searchCriteria: String) -> URLRequest
    
    func searchVehicle(with searchCriteria: String) -> URLRequest
    
    // MARK: - Entity Details
    
    func retrieveVehicleDetails(with vehicleID: String) -> URLRequest
    
    func retrievePersonDetails(with personID: String) -> URLRequest
    
}
