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

    // MARK: - Shared

    /// Perform login
    func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken>

    /// Fetch manifest items
    func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass>


    // MARK: - CAD

    /// Book on to CAD
    func cadBookOn(with request: CADBookOnRequestType, pathTemplate: String?) -> Promise<Void>

    /// Book off from CAD
    func cadBookOff(with request: CADBookOffRequestType, pathTemplate: String?) -> Promise<Void>

    /// Sync all summary details for a patrol group or bounding box
    func cadSyncSummaries<ResponseType: CADSyncResponseType>(with request: CADSyncRequestType, pathTemplate: String?) -> Promise<ResponseType>

    /// Fetch details about an employee
    func cadEmployeeDetails<ResponseType: CADEmployeeDetailsType>(with request: CADEmployeeDetailsRequestType, pathTemplate: String?) -> Promise<ResponseType>

    /// Fetch details about an incident
    func cadIncidentDetails<ResponseType: CADIncidentDetailsType>(with request: CADIncidentDetailsRequestType, pathTemplate: String?) -> Promise<ResponseType>

    /// Fetch details about a resource
    func cadResourceDetails<ResponseType: CADResourceDetailsType>(with request: CADResourceDetailsRequestType, pathTemplate: String?) -> Promise<ResponseType>
}

// Convenience extension for default paths (since you cant have default params in protocol)
public extension CADAPIManagerType {

    func cadBookOn(with request: CADBookOnRequestType) -> Promise<Void> {
        return cadBookOn(with: request, pathTemplate: nil)
    }

    func cadBookOff(with request: CADBookOffRequestType) -> Promise<Void> {
        return cadBookOff(with: request, pathTemplate: nil)
    }

    func cadSyncSummaries<ResponseType: CADSyncResponseType>(with request: CADSyncRequestType) -> Promise<ResponseType> {
        return cadSyncSummaries(with: request, pathTemplate: nil)
    }

    func cadEmployeeDetails<ResponseType: CADEmployeeDetailsType>(with request: CADEmployeeDetailsRequestType) -> Promise<ResponseType> {
        return cadEmployeeDetails(with: request, pathTemplate: nil)
    }

    func cadIncidentDetails<ResponseType: CADIncidentDetailsType>(with request: CADIncidentDetailsRequestType) -> Promise<ResponseType> {
        return cadIncidentDetails(with: request, pathTemplate: nil)
    }

    func cadResourceDetails<ResponseType: CADResourceDetailsType>(with request: CADResourceDetailsRequestType) -> Promise<ResponseType> {
        return cadResourceDetails(with: request, pathTemplate: nil)
    }

}
