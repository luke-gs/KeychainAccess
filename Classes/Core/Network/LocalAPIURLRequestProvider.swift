//
//  LocalAPIURLRequestProvider.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//
//

open class LocalAPIURLRequestProvider<T: APIURLRequestProviderConfigurable>: WebAPIURLRequestProvider {

    public let baseURL: URL

    public typealias Configuration = T
    
    open let localBundle: Bundle
    
    public init(configuration: T) {
        localBundle = Bundle(for: type(of: self))
        baseURL = localBundle.bundleURL
    }
    
    /// Create a access token request.
    ///
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A URLRequest to request for access token.
    open func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> URLRequest {
        guard let url = localBundle.url(forResource: "AccessToken", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    /// Create a credentials validation using basic authentatication request.
    ///
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    /// - Returns: A URLRequest to check validity of the credentials.
    open func basicAuthLoginRequestFor(username: String, password: String) -> URLRequest {
        fatalError()
    }
    
    /// Create a person search request.
    ///
    /// - Parameters:
    ///   - source: The source to search it from
    ///   - parameters: The search criteria
    /// - Returns: A URLRequest to search the person.
    open func searchPerson(from source: T.Source, with parameters: T.PersonSearchParametersType) -> URLRequest {
        guard let url = localBundle.url(forResource: "PersonSearch", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    /// Create a fetch person details request.
    ///
    /// - Parameters:
    ///   - source: The source to fetch the person details from.
    ///   - id: The id of the person to be fetched.
    /// - Returns: A URLRequest to fetch the person details.
    open func fetchPersonDetails(from source: T.Source, with id: String) -> URLRequest {
        guard let url = localBundle.url(forResource: "PersonDetail\(id)", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    /// Create a vehicle search request.
    ///
    /// - Parameters:
    ///   - source: The source to search person from.
    ///   - parameters: The search criteria.
    /// - Returns: A URLRequest to search the vehicle.
    open func searchVehicle(from source: T.Source, with parameters: T.VehicleSearchParametersType) -> URLRequest {
        
        guard let url = localBundle.url(forResource: "VehicleSearch", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    /// Create a fetch vehicle details request.
    ///
    /// - Parameters:
    ///   - source: The source to fetch the vehicle details from.
    ///   - id: The id of the vehicle to be fetched.
    /// - Returns: A URLRequest to fetch the vehicle details.
    open func fetchVehicleDetails(from source: T.Source, with id: String) -> URLRequest {
        guard let url = localBundle.url(forResource: "VehicleDetail\(id)", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    private func throwError(message: String) -> Never {
        fatalError("JSON file not found for \(message)")
    }
}
