//
//  CADIncidentType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

public protocol CADIncidentType {
    var identifier: String! { get }
    var secondaryCode: String! { get }
    var type: String! { get }
    var grade: CADIncidentGradeType! { get }
    var patrolGroup: String! { get }
    var location : CADLocation! { get }
    var createdAt: Date! { get }
    var lastUpdated: Date! { get }
    var details: String! { get }
    var informant : CADIncidentInformantType! { get }
    var locations: [CADLocation]! { get }
    var persons: [CADIncidentPersonType]! { get }
    var vehicles: [CADIncidentVehicleType]! { get }
    var narrative: [CADActivityLogItemType]! { get }

    var status: CADIncidentStatusType { get }
    var coordinate: CLLocationCoordinate2D { get }
    var resourceCount: Int { get }
    var resourceCountString: String? { get }
    var createdAtString: String { get }
}
