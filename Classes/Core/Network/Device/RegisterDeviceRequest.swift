//
//  RegisterDeviceRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

open class RegisterDeviceRequest: Parameterisable {

    /// Request URL as relative path
    open var path: String!

    /// Current version identifier for the application running on the device
    open var appVersion: String!

    /// Unique Id of this device. Could be IMEI, UUID or any other value to unique identify that device
    open var deviceId: String!

    /// What type of device this is. eg iOS/Android
    open var deviceType: String!

    /// Token used to identify this device for push notifications
    open var pushToken: String!

    /// What application registered this device
    open var sourceApp: String!

    /// Request parameters as a dictionary
    open var parameters: [String: Any] {
        return [
            "appVersion": appVersion,
            "deviceId": deviceId,
            "deviceType": deviceType,
            "pushToken": pushToken,
            "sourceApp": sourceApp
        ]
    }

    public init() {
        self.path = "device/register"
    }
}

// MARK: - API Manager method for sending request
public extension APIManager {
    public func registerDevice(with request: RegisterDeviceRequest) -> Promise<Void> {
        let networkRequest = try! NetworkRequest(pathTemplate: request.path, parameters: request.parameters, method: .post)
        return try! APIManager.shared.performRequest(networkRequest, cancelToken: nil).then { _ -> Void in
            // Backend returns ID array we don't care about, so ignore
        }
    }
}

