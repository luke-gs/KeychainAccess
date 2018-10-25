//
//  ManifestCollection+CAD.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Extension for CAD specific manifest categories
///
/// Note: these are defined as vars to allow override in client app
///
public extension ManifestCollection {
    static var activityLogType = ManifestCollection(rawValue: "ActivityLogType")
    static var equipment = ManifestCollection(rawValue: "Equipment")
    static var incidentType = ManifestCollection(rawValue: "IncidentType")
    static var officerLicenceType = ManifestCollection(rawValue: "OfficerLicenceType")
    static var officerCapability = ManifestCollection(rawValue: "OfficerCapability")
    static var patrolGroup = ManifestCollection(rawValue: "PatrolGroup")
    static var patrolType = ManifestCollection(rawValue: "PatrolType")
    static var vehicleCategory = ManifestCollection(rawValue: "VehicleCategory")
    static var welfareCheckReason = ManifestCollection(rawValue: "WelfareCheckReason")

    /// The CAD app specific manifest collections to fetch when syncing
    static var cadCollections: [ManifestCollection] = [.activityLogType,
                                                       .equipment,
                                                       .incidentType,
                                                       .officerLicenceType,
                                                       .officerCapability,
                                                       .patrolGroup,
                                                       .patrolType,
                                                       .vehicleCategory,
                                                       .welfareCheckReason]
}
