//
//  UpdateDeviceLocationRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public struct UpdateDeviceLocationRequest: Parameterisable {
    public typealias ResultClass = [[String: Any]]

    // Request URL as relative path
    public var path: String!

    // TODO: Request parameters as a dictionary
    public var parameters: [String: Any] = [:]

    public init() {
        self.path = "device/location"
    }
}

// MARK: - API Manager method for sending request
public extension APIManager {
    func updateDeviceLocation(with request: UpdateDeviceLocationRequest) -> Promise<Void> {
        let networkRequest = try! NetworkRequest(pathTemplate: request.path, parameters: request.parameters, method: .post)
        return try! APIManager.shared.performRequest(networkRequest, cancelToken: nil).then { _ -> Void in
        }
    }
}
