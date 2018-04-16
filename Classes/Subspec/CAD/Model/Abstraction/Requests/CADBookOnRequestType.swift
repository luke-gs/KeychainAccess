//
//  CADBookOnRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Protocol for book on request
public protocol CADBookOnRequestType: CodableRequest {

    // MARK: - Request Parameters
    var callsign : String { get }
    var category : String? { get }
    var driverEmployeeNumber : String? { get }
    var employees : [CADOfficerType] { get }
    var equipment : [CADEquipmentType] { get }
    var fleetNumber : String? { get }
    var odometer : Int? { get }
    var remarks : String? { get }
    var serial: String? { get }
    var shiftEnd : Date? { get }
    var shiftStart : Date? { get }

}

// MARK: - API Manager method for sending request
public extension APIManager {

    /// Book on to CAD
    public func cadBookOn(with request: CADBookOnRequestType) -> Promise<Void> {
        let networkRequest = try! NetworkRequest(pathTemplate: request.relativePath, parameters: request.parameters, method: .post)
        return try! APIManager.shared.performRequest(networkRequest, cancelToken: nil).done { _ -> Void in
            // No response
        }
    }
}
