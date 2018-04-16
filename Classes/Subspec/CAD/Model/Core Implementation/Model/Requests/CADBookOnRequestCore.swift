//
//  CADBookOnRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// PSCore implementation of book on request
open class CADBookOnRequestCore: CADBookOnRequestType {

    open var relativePath: String {
        return "cad/shift/bookon"
    }

    // MARK: - Request Parameters

    open var callsign : String = ""
    open var category : String?
    open var driverEmployeeNumber : String?
    open var employees : [CADOfficerType] = []
    open var equipment : [CADEquipmentType] = []
    open var fleetNumber : String?
    open var odometer : Int?
    open var remarks : String?
    open var serial: String?
    open var shiftEnd : Date?
    open var shiftStart : Date?

    public init() {
    }

    // MARK: - Encodable

    private enum CodingKeys: String, CodingKey {
        case callsign
        case category
        case driverEmployeeNumber
        case employees
        case equipment
        case fleetNumber
        case odometer
        case remarks
        case serial
        case shiftEnd
        case shiftStart
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(callsign, forKey: CodingKeys.callsign)
        try container.encode(category, forKey: CodingKeys.category)
        try container.encode(driverEmployeeNumber, forKey: CodingKeys.driverEmployeeNumber)
        try container.encode(employees as? [CADOfficerCore], forKey: CodingKeys.employees)
        try container.encode(equipment as? [CADEquipmentCore], forKey: CodingKeys.equipment)
        try container.encode(fleetNumber, forKey: CodingKeys.fleetNumber)
        try container.encode(odometer, forKey: CodingKeys.odometer)
        try container.encode(remarks, forKey: CodingKeys.remarks)
        try container.encode(serial, forKey: CodingKeys.serial)
        try container.encode(shiftEnd, forKey: CodingKeys.shiftEnd)
        try container.encode(shiftStart, forKey: CodingKeys.shiftStart)
    }

}
