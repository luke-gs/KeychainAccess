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

    /// Sync all summary details for a patrol group or bounding box
    open func cadSyncSummaries<ResponseType: CADSyncResponseType>(with request: CADSyncRequestType, pathTemplate: String?) -> Promise<ResponseType> {

        // Use explicit path or construct based on type of sync
        var pathTemplate = pathTemplate
        if pathTemplate == nil {
            if request is CADSyncPatrolGroupRequestType {
                pathTemplate = "cad/sync/patrolgroup/{patrolGroup}"
            } else {
                pathTemplate = "cad/sync/boundingbox"
            }
        }
        return performRequest(request, pathTemplate: pathTemplate!, method: .get)
    }

    /// Fetch details about an employee
    public func cadEmployeeDetails<ResponseType: CADEmployeeDetailsResponseType>(with request: CADEmployeeDetailsRequestType, pathTemplate: String?) -> Promise<ResponseType> {
        return performRequest(request, pathTemplate: pathTemplate ?? "/cad/officer/username/{employeeNumber}")
    }
}

