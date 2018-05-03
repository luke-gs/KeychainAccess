//
//  CADSyncRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for book off request
public protocol CADSyncRequestType: CodableRequestParameters {

    // MARK: - Common Parameters
}


public protocol CADSyncPatrolGroupRequestType: CADSyncRequestType {

    // MARK: - Request Parameters
    var patrolGroup : String { get }
}

public protocol CADSyncBoundingBoxRequestType: CADSyncRequestType {

    // MARK: - Request Parameters
    var northWestLatitude: Int { get }
    var northWestLongitude: Int { get }
    var southEastLatitude: Int { get }
    var southEastLongitude: Int { get }
}
