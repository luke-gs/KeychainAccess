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
public protocol PluginType {

    // Called to modify the request before it's sent.
    func adapt(_ urlRequest: URLRequest) -> URLRequest

    // Called immediately before request is sent, after the modification.
    func willSend(_ request: Alamofire.Request)

    // Called after a response has been received, but before the completion callback is triggered.
    func didReceiveResponse(_ response: Alamofire.DataResponse<Data>)

    // Called after `didReceiveResponse:` but before the completion callback is triggered.
    // This will give the chance for plugin to modify the response if necessary before the completion.
    func processResponse(_ response: Alamofire.DataResponse<Data>) -> Alamofire.DataResponse<Data>

}

// Default implementation for PluginType, plugin might necessary only care about particular event.
public extension PluginType {

    func adapt(_ urlRequest: URLRequest) -> URLRequest {
        return urlRequest
    }

    func willSend(_ request: Alamofire.Request) {

    }

    func didReceiveResponse(_ response: Alamofire.DataResponse<Data>) {

    }

    func processResponse(_ response: Alamofire.DataResponse<Data>) -> Alamofire.DataResponse<Data> {
        return response
    }
}
