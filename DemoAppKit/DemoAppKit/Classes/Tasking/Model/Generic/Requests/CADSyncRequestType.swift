//
//  CADSyncRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for sync request
public protocol CADSyncRequestType: CodableRequestParameters {

    // MARK: - No Common Parameters
}

/// Protocol for patrol group sync request
public protocol CADSyncPatrolGroupRequestType: CADSyncRequestType {

    // MARK: - Request Parameters
    var patrolGroup: String { get }
}

/// Protocol for bounding box sync request
public protocol CADSyncBoundingBoxRequestType: CADSyncRequestType {

    // MARK: - Request Parameters
    var northWestLatitude: Double { get }
    var northWestLongitude: Double { get }
    var southEastLatitude: Double { get }
    var southEastLongitude: Double { get }
}
