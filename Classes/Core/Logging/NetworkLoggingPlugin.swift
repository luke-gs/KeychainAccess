//
//  NetworkLoggingPlugin.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

open class NetworkLoggingPlugin: PluginType {

    private var requests: Set<URLRequest> = []

    private let networkLogger: NetworkLogger

    init(configurations: LoggingConfigurations = MPOLLoggingConfigurations()) {
        self.networkLogger = NetworkLogger(configs: configurations)
    }

    public func willSend(_ request: Request) {
        networkLogger.log(request: request)

        if let urlRequest = request.request {
            self.requests.insert(urlRequest)
        }
    }

    public func didReceiveResponse<T>(_ response: DataResponse<T>) {
        networkLogger.log(response: response)
        if let request = response.request {
            requests.remove(request)
        }
    }
}
