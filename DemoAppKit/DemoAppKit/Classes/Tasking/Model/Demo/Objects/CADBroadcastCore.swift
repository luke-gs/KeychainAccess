//
//  CADBroadcastCore.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

// TODO: Update this to match API when we get a spec, as this is created based on what the UI needs

/// PSCore implementation of class representing a broadcast task
open class CADBroadcastCore: Codable, CADBroadcastDetailsType {

    // MARK: - Network

    open var createdAt: Date?

    open var details: String?

    open var identifier: String

    open var lastUpdated: Date?

    open var location: CADLocationType?

    open var title: String?

    open var type: CADBroadcastCategoryType

    public var narrative: [CADActivityLogItemType]

    public var locations: [CADLocationType]

    public var persons: [CADAssociatedPersonType]

    public var vehicles: [CADAssociatedVehicleType]

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
        return BroadcastAnnotation(identifier: identifier,
                                   source: CADTaskListSourceCore.broadcast,
                                   coordinate: coordinate,
                                   title: title,
                                   subtitle: nil,
                                   usesDarkBackground: false)
    }


    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case createdAt = "createdAt"
        case details = "details"
        case identifier = "identifier"
        case lastUpdated = "lastUpdated"
        case location = "location"
        case narrative = "narrative"
        case title = "title"
        case type = "type"
        case persons = "persons"
        case locations = "locations"
        case vehicles = "vehicles"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        details = try values.decodeIfPresent(String.self, forKey: .details)
        identifier = try values.decode(String.self, forKey: .identifier)
        lastUpdated = try values.decodeIfPresent(Date.self, forKey: .lastUpdated)
        location = try values.decodeIfPresent(CADLocationCore.self, forKey: .location)
        narrative = try values.decodeIfPresent([CADActivityLogItemCore].self, forKey: .narrative) ?? []
        title = try values.decodeIfPresent(String.self, forKey: .title)
        type = try values.decode(CADBroadcastCategoryCore.self, forKey: .type)
        persons = try values.decodeIfPresent([CADIncidentPersonCore].self, forKey: .persons) ?? []
        locations = try values.decodeIfPresent([CADLocationCore].self, forKey: .locations) ?? []
        vehicles = try values.decodeIfPresent([CADIncidentVehicleCore].self, forKey: .vehicles) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
