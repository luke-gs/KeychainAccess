//
//  MPOLAPIManager.swift
//  MPOL
//
//  Created by Herli Halim on 11/5/17.
//
//

import Alamofire

open class MPOLAPIManager {
    
    open let baseURLString: String
    open let baseURL: URL
    
    open let sessionManager: Alamofire.SessionManager
    
    public init(baseURLString: String) {
        self.baseURLString = baseURLString
        baseURL = URL(string: baseURLString)!
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    open func accessTokenRequest(grant: OAuthAuthorizationGrant) -> URLRequest {
        
        let path = "login"
        let requestPath = url(with: path)
        
        let parameters = grant.parameters
        
        // Only known parameters are passed in, if this fail, might as well crash.
        let request: URLRequest = try! URLRequest(url: requestPath, method: .post)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: parameters)
        
        return encodedURLRequest
    }
    
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
