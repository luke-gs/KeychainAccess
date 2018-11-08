//
//  CADSyncResponseType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for sync response
public protocol CADSyncResponseType: Codable {
    var incidents: [CADIncidentType] { get }
    var officers: [CADOfficerType] { get }
    var resources: [CADResourceType] { get }
    var patrols: [CADPatrolType] { get }
    var broadcasts: [CADBroadcastType] { get }
}
