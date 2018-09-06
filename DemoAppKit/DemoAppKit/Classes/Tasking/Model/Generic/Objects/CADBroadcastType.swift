//
//  CADBroadcastType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing a broadcast task
public protocol CADBroadcastType: class, CADTaskListItemModelType {

    // MARK: - Network
    var createdAt: Date? { get set }
    var details: String? { get set }
    var identifier: String { get set }
    var lastUpdated: Date? { get set }
    var location : CADLocationType? { get set }
    var title: String? { get set }
    var type: CADBroadcastCategoryType { get set }

    // MARK: - Generated
    var coordinate: CLLocationCoordinate2D? { get }
    var createdAtString: String? { get }

    var locations: [CADLocationType] { get set }
    var persons: [CADPersonType] { get set }
    var vehicles: [CADVehicleType] { get set }
}

// Protocol for a class representing the full details for an incident.
///
/// This information only gets loaded when viewing an individual incident.
public protocol CADBroadcastDetailsType: CADBroadcastType {

    // MARK: - Network
    var narrative: [CADActivityLogItemType] { get set }
}
