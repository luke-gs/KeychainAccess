//
//  CADIncidentType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADIncidentType {
    var identifier: String! { get }
    var secondaryCode: String! { get }
    var type: String! { get }
    var grade: IncidentGrade! { get }
    var patrolGroup: String! { get }
    var location : SyncDetailsLocation! { get }
    var createdAt: Date! { get }
    var lastUpdated: Date! { get }
    var details: String! { get }
    var informant : SyncDetailsIncidentInformant! { get }
    var locations: [SyncDetailsLocation]! { get }
    var persons: [SyncDetailsIncidentPerson]! { get }
    var vehicles: [SyncDetailsIncidentVehicle]! { get }
    var narrative: [SyncDetailsActivityLogItem]! { get }

    var status: CADIncidentStatusType { get }
    var coordinate: CLLocationCoordinate2D { get }
    var resourceCount: Int { get }
    var resourceCountString: String? { get }
    var createdAtString: String { get }
}
