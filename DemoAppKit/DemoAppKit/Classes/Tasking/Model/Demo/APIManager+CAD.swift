//
//  APIManager+CAD.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/4/18.
//

import Foundation
import PromiseKit
import Alamofire

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

    /// Sync all summary details for a patrol group or bounding box
    open func cadSyncSummaries<ResponseType: CADSyncResponseType>(with request: CADSyncRequestType, pathTemplate: String?) -> Promise<ResponseType> {

        var encoding: ParameterEncoding = JSONEncoding.default

        // Use explicit path or construct based on type of sync
        var pathTemplate = pathTemplate
        if pathTemplate == nil {
            if request is CADSyncPatrolGroupRequestType {
                pathTemplate = "cad/sync/patrolgroup/{patrolGroup}"
            } else {
                pathTemplate = "cad/sync/boundingbox"
                encoding =  URLEncoding.queryString
            }
        }
        return performRequest(request, pathTemplate: pathTemplate!, method: .get, parameterEncoding: encoding)
    }

    /// Fetch details about an incident
    public func cadIncidentDetails<ResponseType: CADIncidentDetailsType>(with request: CADGetDetailsRequestType, pathTemplate: String?) -> Promise<ResponseType> {
        return performRequest(request, pathTemplate: pathTemplate ?? "/cad/incident/{identifier}", method: .get)
    }

    /// Fetch details about a resource
    public func cadResourceDetails<ResponseType: CADResourceDetailsType>(with request: CADGetDetailsRequestType, pathTemplate: String?) -> Promise<ResponseType> {
        return performRequest(request, pathTemplate: pathTemplate ?? "/cad/resource/{identifier}", method: .get)
    }

}
