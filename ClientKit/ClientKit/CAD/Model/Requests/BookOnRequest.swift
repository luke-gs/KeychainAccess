//
//  BookOnRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Request object for the call to /shift/bookOn
open class BookOnRequest: Codable, CADBookOnDetailsType {

    /// The callsign of the resource to book on to.
    open var callsign: String!

    /// The current shift start time of the resource.
    open var shiftStart: Date!

    /// The current shift end time of the resource.
    open var shiftEnd: Date!

    /// The list of officers to book on
    open var officers: [SyncDetailsOfficer]!

    /// The list of equipment items for the resource.
    open var equipment: [SyncDetailsEquipment]!

    /// The fleet number for the resource.
    open var fleetNumber: String!

    /// The optional remarks to populate as part of this book on.
    open var remarks: String!

    /// The driver payrolId for the resource (should be one of the officers in the officers array).
    open var driverpayrollId: String!

    /// The payrollId of the currently logged in officer on the mobile device.
    open var loggedInpayrollId: String!

    /// NOT IN API: The vehicle rego
    open var serial: String!

    /// NOT IN API: The vehicle category
    open var category: String!

    /// NOT IN API: The vehicle odometer
    open var odometer: String!

    /// Default constructor
    public init() { }

    /// Copy constructor (deep copy)
    public init(request: BookOnRequest) {
        self.callsign = request.callsign
        self.shiftStart = request.shiftStart
        self.shiftEnd = request.shiftEnd
        self.officers = request.officers.map { return SyncDetailsOfficer(officer: $0) }
        self.equipment = request.equipment.map { return SyncDetailsEquipment(equipment: $0) }
        self.fleetNumber = request.fleetNumber
        self.remarks = request.remarks
        self.driverpayrollId = request.driverpayrollId
        self.loggedInpayrollId = request.loggedInpayrollId
        self.serial = request.serial
        self.category = request.category
        self.odometer = request.odometer
    }
}
