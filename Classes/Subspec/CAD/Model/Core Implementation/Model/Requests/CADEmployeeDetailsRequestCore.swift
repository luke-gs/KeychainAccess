//
//  CADEmployeeDetailsRequestCore.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore implementation of book off request
open class CADEmployeeDetailsRequestCore: CADEmployeeDetailsRequestType {

    public init(employeeNumber: String) {
        self.employeeNumber = employeeNumber
    }

    // MARK: - Request Parameters

    /// The employee number to search
    open var employeeNumber: String

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case employeeNumber
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(employeeNumber, forKey: CodingKeys.employeeNumber)
    }
}

open class CADSyncBoundingBoxRequestCore: CADSyncBoundingBoxRequestType {
    open var northWestLatitude: CLLocationDegrees
    open var northWestLongitude: CLLocationDegrees
    open var southEastLatitude: CLLocationDegrees
    open var southEastLongitude: CLLocationDegrees
    
    public init(northWestLatitude: CLLocationDegrees, northWestLongitude: CLLocationDegrees, southEastLatitude: CLLocationDegrees, southEastLongitude: CLLocationDegrees) {
        self.northWestLatitude = northWestLatitude
        self.northWestLongitude = northWestLongitude
        self.southEastLatitude = southEastLatitude
        self.southEastLongitude = southEastLongitude
    }
    
    public convenience init(northWestCoordinate: CLLocationCoordinate2D, southEastCoordinate: CLLocationCoordinate2D) {
        self.init(northWestLatitude: northWestCoordinate.latitude,
                  northWestLongitude: northWestCoordinate.longitude,
                  southEastLatitude: southEastCoordinate.latitude,
                  southEastLongitude: southEastCoordinate.longitude)
    }
}
