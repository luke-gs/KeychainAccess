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

    public init() {}

    open var relativePath: String {
        return "cad/shift/bookon"
    }

    // MARK: - Request Parameters

    open var callsign : String!
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

    // MARK: - Codable

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

    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(callsign, forKey: .callsign)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(driverEmployeeNumber, forKey: .driverEmployeeNumber)
        try container.encodeIfPresent(employees as? [CADOfficerCore], forKey: .employees)
        try container.encodeIfPresent(equipment as? [CADEquipmentCore], forKey: .equipment)
        try container.encodeIfPresent(fleetNumber, forKey: .fleetNumber)
        try container.encodeIfPresent(odometer, forKey: .odometer)
        try container.encodeIfPresent(remarks, forKey: .remarks)
        try container.encodeIfPresent(serial, forKey: .serial)
        try container.encodeIfPresent(shiftEnd, forKey: .shiftEnd)
        try container.encodeIfPresent(shiftStart, forKey: .shiftStart)
    }

}
