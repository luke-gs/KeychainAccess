//
//  OAuthAuthorizationGrant.swift
//  MPOL
//
//  Created by Herli Halim on 17/5/17.
//
//

public enum OAuthAuthorizationGrant: Parameterisable {
    
    /// Request token using username and password
    ///
    /// - Parameters:
    ///   - username: The username.
    ///   - password: The password.
    case credentials(username: String, password: String)

    /// An authorization code grant.
    /// Authorization code could be acquired from external system.
    /// - Parameters:
    ///   - authorizationCode: The code acquired from external system to be used to request for access token.
    ///   - clientId: The client ID for the application.
    ///   - redirectURL: The redirectURL that's used in original authorization code request.
    case authorizationCode(String, clientId: String, redirectURL: URL)

    /// A refresh token grant.
    ///
    /// - Parameters:
    ///   - refreshToken: The refresh token.
    case refreshToken(String)

    /// Request token using custom parameters. This is to be used for any non-standard request.
    ///
    /// - Parameters:
    ///    - parameters: The parameters for the request.
    case custom([String: Any])
        
    /// Returns the authorization grant's parameters.
    public var parameters: [String: Any] {
        switch self {
        case .credentials(let username, let password):
            return [
                "grant_type": "password",
                "username": username,
                "password": password,
            ]
        case .refreshToken(let refreshToken):
            return [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
            ]
        case .authorizationCode(let code, let clientId, let redirectURL):
            return [
                "grant_type": "authorization_code",
                "code": code,
                "client_id": clientId,
                "redirect_uri": redirectURL.absoluteString,
            ]
        case .custom(let parameters):
            return parameters
        }

    }
}
