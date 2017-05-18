//
//  WebAPIProtocol.swift
//  Pods
//
//  Created by Herli Halim on 18/5/17.
//
//

import UIKit

public protocol WebAPIURLRequestProvider {
    
    func accessTokenRequest(grant: OAuthAuthorizationGrant) -> URLRequest
    
    func basicAuthenticationLogin(using username: String, password: String) -> URLRequest
    
}
