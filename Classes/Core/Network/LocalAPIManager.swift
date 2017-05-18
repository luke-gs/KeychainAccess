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
    
    private func throwError(message: String) -> Never {
        fatalError("JSON file not found for \(message)")
    }
}
