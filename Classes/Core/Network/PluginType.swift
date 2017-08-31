//
//  PluginType.swift
//  MPOLKit
//
//  Created by Herli Halim on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

// Plugin receives callbacks to perform side effects whenever a request is sent or received.
// It could be used to inject extra headers to the request, network monitoring, etc.
public protocol PluginType: class {

    // Called to modify the request before it's sent.
    func adapt(_ urlRequest: URLRequest) -> URLRequest

    // Called immediately before request is sent, after the modification.
    func willSend(_ request: Alamofire.Request)

    // Called after a response has been received, but before the completion callback is triggered.
    func didReceiveResponse<T>(_ response: Alamofire.DataResponse<T>)

}

// Default implementation for PluginType, plugin might necessary only care about particular event.
public extension PluginType {

    func adapt(_ urlRequest: URLRequest) -> URLRequest {
        return urlRequest
    }

    func willSend(_ request: Alamofire.Request) {

    }

    func didReceiveResponse<T>(_ response: Alamofire.DataResponse<T>) {

    }

}
