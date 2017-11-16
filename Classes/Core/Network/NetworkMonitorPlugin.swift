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

    open func willSend(_ request: Request) {
        NetworkMonitor.shared.networkEventDidStart()
    }

    open func didReceiveResponse(_ response: DataResponse<Data>) {
        NetworkMonitor.shared.networkEventDidEnd()
    }
}
