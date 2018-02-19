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

    // MARK: - Network

    public var callsign: String!

    public var category: String!

    public var driverpayrollId: String!

    public var equipment: [CADEquipmentType]!

    public var fleetNumber: String!

    public var loggedInpayrollId: String!

    public var odometer: String!

    public var officers: [CADOfficerType]!

    public var remarks: String!

    public var serial: String!

    public var shiftEnd: Date!

    public var shiftStart: Date!

    // MARK: - Init

    /// Default constructor
    public required init() { }

    /// Copy constructor (deep copy)
    public required init(request: CADBookOnDetailsType) {
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

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        MPLUnimplemented()
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
