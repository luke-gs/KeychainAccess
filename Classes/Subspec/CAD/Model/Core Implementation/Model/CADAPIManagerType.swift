//
//  CADAPIManagerType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PromiseKit

/// Protocol for API manager methods used in CAD. To be implemented in client app/kit
public protocol CADAPIManagerType {

    /// Perform login
    func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken>

    /// Book on to CAD
    func cadBookOn(with request: CADBookOnRequestType) -> Promise<Void>

    /// Book off from CAD
    func cadBookOff(with request: CADBookOffRequestType) -> Promise<Void>

    /// Fetch details about an officer by username
    func cadOfficerByUsername(username: String) -> Promise<CADOfficerDetailsResponse>

    /// Fetch all sync details
    func cadSyncDetails(request: CADSyncRequest) -> Promise<CADSyncResponse>

    /// Fetch manifest items
    func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass>

}

