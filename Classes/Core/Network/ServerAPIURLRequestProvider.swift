//
//  ServerAPIURLRequestProvider.swift
//  MPOLKit
//
//  Created by Herli Halim on 7/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

import Wrap

public protocol APIURLRequestProviderConfigurable {
    
    associatedtype Source: EntitySource
    
    associatedtype PersonSearchParametersType: Parameterisable = PersonSearchParameters
    associatedtype VehicleSearchParametersType: Parameterisable = VehicleSearchParameters
    
    var url: URLConvertible { get }
}

open class ServerAPIURLRequestProvider<T: APIURLRequestProviderConfigurable> : WebAPIURLRequestProvider {
    
    public typealias Configuration = T
    
    open var baseURL: URL
    private let urlQueryBuilder = URLQueryBuilder()
    
    public init(configuration: Configuration) {
        self.baseURL = try! configuration.url.asURL()
    }

    // MARK: - Authentications
    
    /// Create an get access token request.
    ///
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A URLRequest to get access token.
    open func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> URLRequest {
        
        let path = "login"
        let requestPath = url(with: path)
        
        let parameters = grant.parameters
        
        // Only known parameters are passed in, if this fail, might as well crash.
        let request: URLRequest = try! URLRequest(url: requestPath, method: .post)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: parameters)
        
        return encodedURLRequest
    }
    
    
    /// Create a credentials validation request using basic authentication.
    ///
    /// - Parameters:
    ///   - username: The username.
    ///   - password: The password.
    /// - Returns: A URLRequest to check validity of the credentials.
    open func basicAuthLoginRequestFor(username: String, password: String) -> URLRequest {
        
        let path = "login"
        let requestPath = url(with: path)
        
        var headers: HTTPHeaders = [:]
        
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
    
        let request: URLRequest = try! URLRequest(url: requestPath, method: .post, headers: headers)
        return request
    }
    
    // MARK: - Person
    
    /// Create a person search request.
    ///
    /// - Parameters:
    ///   - source: The source to search person from.
    ///   - parameters: The search criteria.
    /// - Returns: A URLRequest to search the person.
    open func searchPerson(from source: Configuration.Source, with parameters: Configuration.PersonSearchParametersType) -> URLRequest {
        let path = "{source}/entity/person/search"
        let result = try! urlQueryBuilder.urlPathWith(template: path, parameters: parameters.parameters)
        
        let requestPath = url(with: result.path)
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: result.parameters)
        
        return encodedURLRequest
    }
    
    
    /// Create a fetch person details request.
    ///
    /// - Parameters:
    ///   - source: The source to fetch the person details from.
    ///   - id: The id of the person to be fetched.
    /// - Returns: A URLRequest to fetch the person details.
    open func fetchPersonDetails(from source: Configuration.Source, with id: String) -> URLRequest {
        let path = ""
        let requestPath = url(with: path)
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        return request
    }
    
    
    // MARK: - Vehicle
    
    /// Create a vehicle search request.
    ///
    /// - Parameters:
    ///   - source: The source to search person from.
    ///   - parameters: The search criteria.
    /// - Returns: A URLRequest to search the vehicle.
    open func searchVehicle(from source: Configuration.Source, with parameters: Configuration.VehicleSearchParametersType) -> URLRequest {
        let path = ""
        let requestPath = url(with: path)
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        return request
    }
    
    
    /// Create a fetch vehicle details request.
    ///
    /// - Parameters:
    ///   - source: The source to fetch the vehicle details from.
    ///   - id: The id of the vehicle to be fetched.
    /// - Returns: A URLRequest to fetch the vehicle details.
    open func fetchVehicleDetails(from source: Configuration.Source, with id: String) -> URLRequest {
        let path = ""
        let requestPath = url(with: path)
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        return request
    }
    
    /*
    open func searchVehicle(with searchCriteria: String) -> URLRequest {
        let path = "mpol/entity/vehicle/search"
        let requestPath = url(with: path)
        
        let parameters = [ "criteria": searchCriteria ]
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: parameters)
        
        return encodedURLRequest
        
    }
    
    open func retrieveVehicleDetails(with vehicleID: String) -> URLRequest {
        let path = "mpol/entity/vehicle/\(vehicleID)"
        let requestPath = url(with: path)
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        return request
    }
    
    open func searchPerson(with searchCriteria: String) -> URLRequest {
        let path = "mpol/entity/person/search"
        let requestPath = url(with: path)
        
        let parameters = [ "criteria": searchCriteria ]
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: parameters)
        
        return encodedURLRequest
    }
    
    open func retrievePersonDetails(with personID: String) -> URLRequest {
        let path = "mpol/entity/person/\(personID)"
        let requestPath = url(with: path)
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .get)
        return request
    }
 */
    
    
    // MARK : - Internal Utilities
    func url(with path: String) -> URL {
        return baseURL.appendingPathComponent(path)
    }
    
}
