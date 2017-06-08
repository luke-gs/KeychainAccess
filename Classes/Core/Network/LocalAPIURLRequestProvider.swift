//
//  LocalAPIURLRequestProvider.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//
//

open class LocalAPIURLRequestProvider<T: APIURLRequestProviderConfigurable>: WebAPIURLRequestProvider {
    
    public typealias Configuration = T
    
    open let localBundle: Bundle
    
    public init(configuration: T) {
        localBundle = Bundle(for: type(of: self))
    }
    
    /// Create a access token request.
    ///
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A URLRequest to request for access token.
    open func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> URLRequest {
        fatalError()
    }
    
    /// Create a person search request.
    ///
    /// - Parameters:
    ///   - source: The source to search it from
    ///   - parameters: The search criteria
    /// - Returns: A URLRequest to search the person.
    open func searchPerson(from source: T.Source, with parameters: T.PersonSearchParametersType) -> URLRequest {
        fatalError()
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

    private func throwError(message: String) -> Never {
        fatalError("JSON file not found for \(message)")
    }
}
