//
//  CADIncidentType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

/// Protocol for a class representing an incident
public protocol CADIncidentType: class, CADTaskListItemModelType {

    // MARK: - Network
    var identifier: String { get set }
    var secondaryCode: String? { get set }
    var type: String? { get set }
    var grade: CADIncidentGradeType { get set }
    var patrolGroup: String? { get set }
    var location : CADLocationType? { get set }
    var createdAt: Date? { get set }
    var lastUpdated: Date? { get set }
    var details: String? { get set }
    var informant : CADIncidentInformantType? { get set }
    var locations: [CADLocationType] { get set }
    var persons: [CADIncidentPersonType] { get set }
    var vehicles: [CADIncidentVehicleType] { get set }
    var narrative: [CADActivityLogItemType] { get set }

    // MARK: - Generated
    var status: CADIncidentStatusType { get }
    var coordinate: CLLocationCoordinate2D? { get }
    var resourceCount: Int { get }
    var resourceCountString: String? { get }
    var createdAtString: String? { get }
}
