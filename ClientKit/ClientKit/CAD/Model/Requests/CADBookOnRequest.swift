//
//  CADBookOnRequest.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// PSCore implementation for request details used to book on a resource
open class CADBookOnRequest: Codable, CADBookOnDetailsType {

    // MARK: - Network

    open var callsign: String = ""

    open var category: String?

    open var driverpayrollId: String?

    open var equipment: [CADEquipmentType] = []

    open var fleetNumber: String?

    open var loggedInpayrollId: String?

    open var odometer: String?

    open var officers: [CADOfficerType] = []

    open var remarks: String?

    open var serial: String?

    open var shiftEnd: Date?

    open var shiftStart: Date?

    // MARK: - Init

    /// Default constructor
    public required init() {
    }

    /// Copy constructor (deep copy)
    public required init(request: CADBookOnDetailsType) {
        self.callsign = request.callsign
        self.shiftStart = request.shiftStart
        self.shiftEnd = request.shiftEnd
        self.officers = request.officers.map { return CADOfficerCore(officer: $0) }
        self.equipment = request.equipment.map { return CADEquipmentCore(equipment: $0) }
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
