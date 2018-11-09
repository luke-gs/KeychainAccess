//
//  CADPatrolCore.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation
import CoreKit

// TODO: Update this to match API when we get a spec, as this is created based on what the UI needs

/// PSCore implementation of class representing a patrol task
open class CADPatrolCore: Codable, CADPatrolDetailsType {

    // MARK: - Network

    open var createdAt: Date?

    open var details: String?

    open var identifier: String

    open var lastUpdated: Date?

    open var location: CADLocationType?

    open var patrolGroup: String?

    open var status: CADPatrolStatusType

    open var subtype: String?

    open var type: String?

    public var locations: [CADLocationType]

    public var persons: [CADAssociatedPersonType]

    public var vehicles: [CADAssociatedVehicleType]

    public var narrative: [CADActivityLogItemType]

    // MARK: - Generated

    open var createdAtString: String? {
        return createdAt?.asPreferredDateTimeString()
    }

    open var coordinate: CLLocationCoordinate2D? {
        return location?.coordinate
    }

    // MARK: - CADTaskListItemModelType

    /// Create a map annotation for the task list item if location is available
    open func createAnnotation() -> TaskAnnotation? {
        guard let coordinate = coordinate else { return nil }
        return PatrolAnnotation(identifier: identifier,
                                source: CADTaskListSourceCore.patrol,
                                coordinate: coordinate,
                                title: type,
                                subtitle: nil,
                                usesDarkBackground: status.useDarkBackgroundOnMap)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case createdAt = "createdAt"
        case details = "details"
        case identifier = "identifier"
        case lastUpdated = "lastUpdated"
        case location = "location"
        case patrolGroup = "patrolGroup"
        case status = "status"
        case subtype = "subtype"
        case type = "type"
        case locations = "locations"
        case persons = "persons"
        case vehicles = "vehicles"
        case narrative = "narrative"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        details = try values.decodeIfPresent(String.self, forKey: .details)
        identifier = try values.decode(String.self, forKey: .identifier)
        lastUpdated = try values.decodeIfPresent(Date.self, forKey: .lastUpdated)
        location = try values.decodeIfPresent(CADLocationCore.self, forKey: .location)
        patrolGroup = try values.decodeIfPresent(String.self, forKey: .patrolGroup)
        status = try values.decodeIfPresent(CADPatrolStatusCore.self, forKey: .status) ?? .assigned
        subtype = try values.decodeIfPresent(String.self, forKey: .subtype)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        persons = try values.decodeIfPresent([CADAssociatedPersonCore].self, forKey: .persons) ?? []
        locations = try values.decodeIfPresent([CADLocationCore].self, forKey: .locations) ?? []
        vehicles = try values.decodeIfPresent([CADAssoctiatedVehicleCore].self, forKey: .vehicles) ?? []
        narrative = try values.decodeIfPresent([CADActivityLogItemCore].self, forKey: .narrative) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
