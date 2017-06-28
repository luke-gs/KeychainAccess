//
//  WebAPIURLRequestProvider.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//
//

import MPOLKit

public protocol WebAPIURLRequestProvider {
    
    associatedtype Configuration: APIURLRequestProviderConfigurable
    
    var baseURL: URL { get }
    
    // MARK: - Authentications
    
    /// Create a access token request.
    ///
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A URLRequest to request for access token.
    func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> URLRequest
    
    /// Create a credentials validation using basic authentication request.
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
    
    /// Create a fetch person details request.
    ///
    /// - Parameters:
    ///   - source: The source to fetch the person details from.
    ///   - id: The id of the person to be fetched.
    /// - Returns: A URLRequest to fetch the person details.
    func fetchPersonDetails(from source: Configuration.Source, with id: String) -> URLRequest
    
    /// Create a vehicle search request.
    ///
    /// - Parameters:
    ///   - source: The source to search person from.
    ///   - parameters: The search criteria.
    /// - Returns: A URLRequest to search the vehicle.
    func searchVehicle(from source: Configuration.Source, with parameters: Configuration.VehicleSearchParametersType) -> URLRequest
    
    /// Create a fetch vehicle details request.
    ///
    /// - Parameters:
    ///   - source: The source to fetch the vehicle details from.
    ///   - id: The id of the vehicle to be fetched.
    /// - Returns: A URLRequest to fetch the vehicle details.
    func fetchVehicleDetails(from source: Configuration.Source, with id: String) -> URLRequest
    
}
