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
    open func getOfficerByUsername(username: String) -> Promise<Data> {

        let path = "/officer/username/{username}"
        let parameters = ["username": username]

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        return firstly {
            return try! performRequest(networkRequest)
        }.then { (data, response) in
            return data
        }.catch { (error) in
            print(error)
        }
    }

    open func syncSummaries() -> Promise<CADSyncSummaries> {
        let path = "/sync/summaries"

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: [:], method: .post)
        return firstly {
            return try! performRequest(networkRequest)
        }.then { arg -> Promise<CADSyncSummaries> in
            guard let json = try! JSONSerialization.jsonObject(with: arg.0, options: []) as? [String: AnyObject] else { throw UnboxError.customUnboxingFailed }
            return Promise(value: CADSyncSummaries(fromDictionary: json))
        }.catch { (error) in
            print(error)
        }
    }
}
