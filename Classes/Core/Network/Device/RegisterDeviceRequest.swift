//
//  RegisterDeviceRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public struct RegisterDeviceRequest: Parameterisable {
    public typealias ResultClass = [[String: Any]]

    // Request URL as relative path
    public var path: String!

    public var deviceId: String!

    public var pushToken: String!

    public var appVersion: String!

    public var deviceType: String!

    public var sourceApp: String!

    // Request parameters as a dictionary
    public var parameters: [String: Any] {
        return [
            "deviceId": deviceId,
            "pushToken": pushToken,
            "appVersion": appVersion,
            "deviceType": deviceType,
            "sourceApp": sourceApp
        ]
    }

    public init() {
        self.path = "device/register"
    }

}

// MARK: - API Manager method for sending request
public extension APIManager {
    func registerDevice(with request: RegisterDeviceRequest) -> Promise<Void> {
        let networkRequest = try! NetworkRequest(pathTemplate: request.path, parameters: request.parameters, method: .post)
        return try! APIManager.shared.performRequest(networkRequest, cancelToken: nil).then { _ -> Void in
        }
    }
}

