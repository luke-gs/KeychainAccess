//
//  MPOLAPIManager.swift
//  MPOL
//
//  Created by Herli Halim on 11/5/17.
//
//

import Alamofire

public class MPOLAPIManager {
    
    public let baseURLString: String
    public let baseURL: URL
    
    public let sessionManager: Alamofire.SessionManager
    
    public init(baseURLString: String) {
        self.baseURLString = baseURLString
        baseURL = URL(string: baseURLString)!
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    public func accessTokenRequest(using username: String, password: String) -> URLRequest {
        
        let path = "login"
        let requestPath = baseURL.appendingPathComponent(path)
        
        let parameters = [ "username" : username, "password" : password, "grant_type" : "password" ]
        
        // Only known parameters are passed in, if this fail, might as well crash.
        let request: URLRequest = try! URLRequest(url: requestPath, method: .post)
        let encodedURLRequest = try! URLEncoding.default.encode(request, with: parameters)
        
        return encodedURLRequest
    }
    
    public func basicAuthenticationLogin(using username: String, password: String) -> URLRequest {
        
        let path = "login"
        let requestPath = baseURL.appendingPathComponent(path)
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        let request: URLRequest = try! URLRequest(url: requestPath, method: .post, headers: headers)
        return request
    }
    
}
