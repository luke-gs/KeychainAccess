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

    /// Fetch details about an offier by username.
    ///
    /// - Parameters:
    ///   - username: The officer username
    /// - Returns: A promise to return a X.
    open func cadOfficerByUsername(username: String) -> Promise<[String: Any]> {

        let path = "/cad/officer/username/{username}"
        let parameters = ["username": username]

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        return firstly {
            return try! performRequest(networkRequest, using: APIManager.JSONObjectResponseSerializer())
        }.then { json in
            // TODO: convert to model object
            return json
        }
    }

    open func cadSyncSummaries() -> Promise<CADSyncSummaries> {
        let path = "/cad/sync/summaries"

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: [:], method: .post)
        return firstly {
            return try! performRequest(networkRequest, using: APIManager.JSONObjectResponseSerializer())
        }.then { json in
            return CADSyncSummaries(fromDictionary: json)
        }
    }
}
