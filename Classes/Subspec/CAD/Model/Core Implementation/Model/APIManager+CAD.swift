//
//  APIManager+CAD.swift
//  Alamofire
//
//  Created by Trent Fitzgibbon on 30/4/18.
//

import Foundation
import PromiseKit

/// Extension for APIManager for CAD specific network requests
extension APIManager: CADAPIManagerType {

    /// Book on to CAD
    open func cadBookOn(with request: CADBookOnRequestType, pathTemplate: String? = nil) -> Promise<Void> {
        return performRequest(request, pathTemplate: pathTemplate ?? "cad/shift/bookon", method: .post)
    }

    /// Book off from CAD
    public func cadBookOff(with request: CADBookOffRequestType, pathTemplate: String? = nil) -> Promise<Void> {
        return performRequest(request, pathTemplate: pathTemplate ?? "cad/shift/bookoff", method: .put)
    }


    /// Fetch details about an officer by username
    open func cadOfficerByUsername(username: String) -> Promise<CADOfficerDetailsResponse> {

        let path = "/cad/officer/username/{username}"
        let parameters = ["username": username]

        let networkRequest = try! NetworkRequest(pathTemplate: path, parameters: parameters)
        return firstly {
            return try! performRequest(networkRequest)
            }.map { (data, response) in
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
            }.map { (data, response) in
                return try JSONDecoder.decode(data, to: CADSyncResponse.self)
        }
    }
}

