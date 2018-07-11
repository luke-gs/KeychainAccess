//
//  SessionPlugin.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Plugin that will inject **X-Session-ID**, **X-Device-ID**, **X-Transaction-ID**, and **X-User-ID**
/// to the header of requests. UserID and SessionID will be sourced from UserSession.current.
public struct SessionPlugin: PluginType {

    enum Keys: String {
        case sessionID = "X-Session-ID"
        case deviceID = "X-Device-ID"
        case transactionID = "X-Transaction-ID"
        case userID = "X-User-ID"
    }

    public let deviceID: String

    public init(deviceID: String) {
        self.deviceID = deviceID
    }
    
    public func adapt(_ urlRequest: URLRequest) -> Promise<URLRequest> {
        var adaptedRequest = urlRequest

        // Data from sessions
        let session = UserSession.current
        adaptedRequest.setValue(session.sessionID, forHTTPHeaderField: Keys.sessionID.rawValue)
        if let userID = session.user?.username {
            adaptedRequest.setValue(session.user?.username, forHTTPHeaderField: Keys.userID.rawValue)
        }

        // Data from App
        adaptedRequest.setValue(deviceID, forHTTPHeaderField: Keys.deviceID.rawValue)

        // Generated Data
        adaptedRequest.setValue(UUID().uuidString, forHTTPHeaderField: Keys.transactionID.rawValue)

        return Promise.value(adaptedRequest)
    }
}

