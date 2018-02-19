//
//  SyncDetailsPatrol.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation
import MPOLKit

// TODO: Update this to match API when we get a spec, as this is created based on what the UI needs

open class SyncDetailsPatrol: Codable, CADPatrolType {

    // MARK: - Network

    public var createdAt: Date!

    public var details: String!

    public var identifier: String!

    public var lastUpdated: Date!

    public var location: CADLocationType!

    public var patrolGroup: String!

    public var status: String!

    public var subtype: String!

    public var type: String!

    // MARK: - Generated

    open var createdAtString: String {
        return DateFormatter.preferredDateTimeStyle.string(from: createdAt)
    }

    open var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }

    /// Status as a type that is client specific
    open var statusType: CADPatrolStatusType {
        get {
            return CADClientModelTypes.patrolStatus.init(rawValue: status) ?? CADClientModelTypes.patrolStatus.defaultCase
        }
        set {
            status = newValue.rawValue
        }
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
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        details = try values.decodeIfPresent(String.self, forKey: .details)
        identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        lastUpdated = try values.decodeIfPresent(Date.self, forKey: .lastUpdated)
        location = try values.decodeIfPresent(SyncDetailsLocation.self, forKey: .location)
        patrolGroup = try values.decodeIfPresent(String.self, forKey: .patrolGroup)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        subtype = try values.decodeIfPresent(String.self, forKey: .subtype)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}

