//
//  CADBookOnRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Protocol for book on request
public protocol CADBookOnRequestType: CodableRequestParameters {

    // MARK: - Request Parameters
    var callsign: String! { get }
    var category: String? { get }
    var driverId: String? { get }
    var employees: [CADOfficerType] { get }
    var equipment: [CADEquipmentType] { get }
    var odometer: Int? { get }
    var remarks: String? { get }
    var serial: String? { get }
    var shiftEnd: Date? { get }
    var shiftStart: Date? { get }

}
