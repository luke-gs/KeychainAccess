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

    /// Closure for encoding app specific officers
    static public var encodeOfficers: ((KeyedEncodingContainer<CADBookOnRequestCore.CodingKeys>, CADBookOnRequestCore.CodingKeys, [CADOfficerType]) throws -> Void)?

    public init() {}

    // MARK: - Request Parameters

    open var callsign: String!
    open var category: String?
    open var driverId: String?
    open var employees: [CADOfficerType] = []
    open var equipment: [CADEquipmentType] = []
    open var odometer: Int?
    open var remarks: String?
    open var serial: String?
    open var shiftEnd: Date?
    open var shiftStart: Date?

    // MARK: - CodableRequestParameters

    public var parametersEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    // MARK: - Codable

    public enum CodingKeys: String, CodingKey {
        case callsign
        case category
        case driverId
        case employees
        case equipment
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
        try container.encodeIfPresent(driverId, forKey: .driverId)
        try container.encodeIfPresent(equipment as? [CADEquipmentCore], forKey: .equipment)
        try container.encodeIfPresent(odometer, forKey: .odometer)
        try container.encodeIfPresent(remarks, forKey: .remarks)
        try container.encodeIfPresent(serial, forKey: .serial)
        try container.encodeIfPresent(shiftEnd, forKey: .shiftEnd)
        try container.encodeIfPresent(shiftStart, forKey: .shiftStart)

        // Encode officers using injected closure with explicit type
        try CADBookOnRequestCore.encodeOfficers?(container, .employees, employees)
    }

}
