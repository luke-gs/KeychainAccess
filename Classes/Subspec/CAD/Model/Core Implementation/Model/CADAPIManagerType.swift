//
//  CADAPIManagerType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PromiseKit
import Alamofire
import Unbox

/// Protocol for API manager methods used in CAD. Used so we can mock out API manager for demo json
public protocol CADAPIManagerType {

    /// Perform login
    func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken>

    /// Fetch details about an officer by username
    func cadOfficerByUsername(username: String) -> Promise<CADOfficerDetailsResponse>

    /// Fetch all sync details
    func cadSyncDetails(request: CADSyncRequest) -> Promise<CADSyncResponse>

    /// Fetch manifest items
    func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass>
}

