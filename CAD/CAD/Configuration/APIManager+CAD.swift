//
//  APIManager+CAD.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire
import MPOLKit

/// Extension for APIManager for CAD specific network requests
extension APIManager: CADAPIManagerType {

    /// Fetch details about an officer by username
    open func cadOfficerByUsername(username: String) -> Promise<CADOfficerDetailsResponse> {

        let path = "/cad/officer/username/{username}"
        let parameters = ["username": username]

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        return firstly {
            return try! performRequest(networkRequest)
            }.then { (data, response) in
                return try JSONDecoder.decode(data, to: CADOfficerDetailsResponse.self)
        }
    }

    /// Fetch all sync details
    open func cadSyncDetails(request: CADSyncRequest) -> Promise<CADSyncResponse> {
        // TODO: convert request to params
        let path = "/cad/sync/details"

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: [:], method: .post)
        return firstly {
            return try! performRequest(networkRequest)
            }.then { (data, response) in
                return try JSONDecoder.decode(data, to: CADSyncResponse.self)
        }
    }
}

