//
//  AuthenticationHeaderAdapter.swift
//  MPOL
//
//  Created by Herli Halim on 4/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire

public enum HTTPAuthenticationMode: Equatable {
    
    /// Basic Authentication.
    ///
    /// - parameter username: The username.
    /// - parameter password: The password.
    case basicAuthentication(username: String, password: String)
    
    /// Access Token Authentication.
    ///
    /// - parameter token: The OAuth access token.
    case accessTokenAuthentication(token: OAuthAccessToken)
    
    /// Returns the authentication encoded as `String` suitable for the HTTP
    /// `Authorization` header.
    fileprivate var authorizationHeader: (key: String, value: String)? {
        switch self {
        case .basicAuthentication(let username, let password):
            return Request.authorizationHeader(user: username, password: password)
        case .accessTokenAuthentication(let accessToken):
            return (key: "Authorization", value: "\(accessToken.type) \(accessToken.accessToken)")
        }
    }
}

// MARK: - Equatable
public func == (lhs: HTTPAuthenticationMode, rhs: HTTPAuthenticationMode) -> Bool {
    switch (lhs, rhs) {
    case (.basicAuthentication(let lusername, let lpassword), .basicAuthentication(let rusername, let rpassword)):
        return lusername == rusername &&
            lpassword == rpassword
    case (.accessTokenAuthentication(let laccessToken), .accessTokenAuthentication(let raccessToken)):
        return laccessToken == raccessToken
    default:
        return false
    }
}


public class AuthenticationHeaderAdapter: RequestAdapter {
    
    let authenticationMode: HTTPAuthenticationMode
    
    public init(authenticationMode: HTTPAuthenticationMode) {
        self.authenticationMode = authenticationMode
    }
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
        guard let header = authenticationMode.authorizationHeader else {
            return urlRequest
        }
        
        var adaptedRequest = urlRequest
        adaptedRequest.addValue(header.value, forHTTPHeaderField: header.key)
        
        return adaptedRequest
    }
    
}
