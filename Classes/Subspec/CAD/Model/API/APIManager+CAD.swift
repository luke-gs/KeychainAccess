//
//  APIManager+CAD.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PromiseKit
import Alamofire
import Unbox

/// Extension for APIManager for CAD specific network requests
extension APIManager {

    /// Fetch details about an officer by username
    open func cadOfficerByUsername(username: String) -> Promise<OfficerDetailsResponse> {

        let path = "/cad/officer/username/{username}"
        let parameters = ["username": username]

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        return firstly {
            return try! performRequest(networkRequest)
        }.then { (data, response) in
            return try JSONDecoder.decode(data, to: OfficerDetailsResponse.self)
        }
    }

    /// Fetch all sync details
    open func cadSyncDetails(request: SyncDetailsRequest) -> Promise<SyncDetailsResponse> {
        // TODO: convert request to params
        let path = "/cad/sync/details"

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: [:], method: .post)
        return firstly {
            return try! performRequest(networkRequest)
        }.then { (data, response) in
            return try JSONDecoder.decode(data, to: SyncDetailsResponse.self)
        }
    }
}
