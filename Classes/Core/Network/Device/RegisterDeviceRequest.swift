//
//  RegisterDeviceRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

open class RegisterDeviceRequest: CodableRequest {

    open var relativePath: String {
        return "device/register"
    }

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

    // MARK: - Codable

    public enum CodingKeys: String, CodingKey {
        case appVersion
        case deviceId
        case deviceType
        case pushToken
        case sourceApp
    }

}

// MARK: - API Manager method for sending request
public extension APIManager {
    public func registerDevice(with request: RegisterDeviceRequest) -> Promise<Void> {
        // Send request and ignore response backend internal ID array)
        return performRequest(request, method: .post)
    }
}

