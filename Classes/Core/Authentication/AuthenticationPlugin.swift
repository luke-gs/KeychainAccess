//
//  AuthenticationPlugin.swift
//  MPOLKit
//
//  Created by Herli Halim on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class AuthenticationPlugin: PluginType {

    open let authenticationMode: HTTPAuthenticationMode

    public init(authenticationMode: HTTPAuthenticationMode) {
        self.authenticationMode = authenticationMode
    }

    open func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
        let header = authenticationMode.authorizationHeader
        
        var adaptedRequest = urlRequest
        adaptedRequest.addValue(header.value, forHTTPHeaderField: header.key)

        return Promise(value: adaptedRequest)
    }
    
}
