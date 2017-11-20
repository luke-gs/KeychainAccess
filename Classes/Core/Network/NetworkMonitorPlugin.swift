//
//  NetworkMonitorPlugin.swift
//  MPOLKit
//
//  Created by Kara Valentine on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

open class NetworkMonitorPlugin: PluginType {

    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(networkActivityDidBegin), name: .NetworkActivityDidBegin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkActivityDidEnd), name: .NetworkActivityDidEnd, object: nil)
    }

    open func willSend(_ request: Request) {
        NetworkMonitor.shared.networkEventDidStart()
    }

    open func didReceiveResponse(_ response: DataResponse<Data>) {
        NetworkMonitor.shared.networkEventDidEnd()
    }

    @objc func networkActivityDidBegin() {
        if !UIApplication.shared.isNetworkActivityIndicatorVisible {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    @objc func networkActivityDidEnd() {
        if UIApplication.shared.isNetworkActivityIndicatorVisible {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
