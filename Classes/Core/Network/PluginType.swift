//
//  PluginType.swift
//  MPOLKit
//
//  Created by Herli Halim on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

public protocol PluginType: class {

    func adapt(_ urlRequest: URLRequest) -> URLRequest

    func willSend(_ request: Alamofire.Request)

    // Alamofire.Request is responsible for sending a request and receiving the response and associated data from the server.
    func didReceiveResponse(_ request: Alamofire.Request)

}

// Default implementation for PluginType, plugin might necessary only care about particular event.
public extension PluginType {

    func adapt(_ urlRequest: URLRequest) -> URLRequest {
        return urlRequest
    }

    func willSend(_ request: Alamofire.Request) {

    }

    func didReceiveResponse(_ request: Alamofire.Request) {

    }

}
