//
//  LocalAPIManager.swift
//  Pods
//
//  Created by Herli Halim on 18/5/17.
//
//


open class LocalAPIManager: WebAPIURLRequestProvider {
    
    open let localBundle: Bundle
    
    public init() {
        localBundle = Bundle(for: type(of: self))
    }

    open func accessTokenRequest(grant: OAuthAuthorizationGrant) -> URLRequest {
        guard let url = localBundle.url(forResource: "AccessToken", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    open func basicAuthenticationLogin(using username: String, password: String) -> URLRequest {
        fatalError("\(#function) is not implemented")
    }
    
    // MARK: - Entity Search
    
    open func searchPerson(with searchCriteria: String) -> URLRequest {
        guard let url = localBundle.url(forResource: "PersonSearch", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    open func searchVehicle(with searchCriteria: String) -> URLRequest {
        guard let url = localBundle.url(forResource: "VehicleSearch", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    // MARK: - Entity Details
    
    open func retrievePersonDetails(with personID: String) -> URLRequest {
        guard let url = localBundle.url(forResource: "PersonDetail\(personID)", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }

    
    open func retrieveVehicleDetails(with vehicleID: String) -> URLRequest {
        guard let url = localBundle.url(forResource: "VehicleDetail\(vehicleID)", withExtension: "json") else {
            throwError(message: #function)
        }
        return URLRequest(url: url)
    }
    
    
    private func throwError(message: String) -> Never {
        fatalError("JSON file not found for \(message)")
    }
}
