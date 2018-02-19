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
import MPOLKit

/// Protocol for API manager methods used in CAD. Used so we can mock out API manager for demo json
public protocol CADAPIManager {

    /// Perform login
    func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken>

    /// Fetch details about an officer by username
    func cadOfficerByUsername(username: String) -> Promise<CADOfficerDetailsResponse>

    /// Fetch all sync details
    func cadSyncDetails(request: CADSyncRequest) -> Promise<CADSyncResponse>

    /// Fetch manifest items
    func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass>
}

/// Extension for APIManager for CAD specific network requests
extension APIManager: CADAPIManager {

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
