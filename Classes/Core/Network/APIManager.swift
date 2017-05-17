//
//  APIManager.swift
//  MPOL
//
//  Created by Herli Halim on 11/5/17.
//
//

import Alamofire

open class APIManager {
    
    open let baseURL: URL
    
    open let sessionManager: Alamofire.SessionManager
    
    public init(baseURL: URLConvertible) {

        self.baseURL = try! baseURL.asURL()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    // MARK: - Authentications
    
    /// Create a access token request.
    ///
    /// - Parameter grant: The grant type and required field for it.
    /// - Returns: A URLRequest to request for access token.
    open func accessTokenRequest(grant: OAuthAuthorizationGrant) -> URLRequest {
        
        let path = "login"
        let requestPath = url(with: path)
        
        let parameters = grant.parameters
        
        // Only known parameters are passed in, if this fail, might as well crash.
        let request: URLRequest = try! URLRequest(url: requestPath, method: .post)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: parameters)
        
        return encodedURLRequest
    }
    
    
    /// Create a credentials validation using basic authentatication request.
    ///
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    /// - Returns: A URLRequest to check validity of the credentials.
    open func basicAuthenticationLogin(using username: String, password: String) -> URLRequest {
        
        let path = "login"
        let requestPath = url(with: path)
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .post, headers: headers)
        return request
    }
    
    // MARK : - Internal Utilities
    func url(with path: String) -> URL {
        return baseURL.appendingPathComponent(path)
    }
}
