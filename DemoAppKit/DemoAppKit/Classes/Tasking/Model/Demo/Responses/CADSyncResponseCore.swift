//
//  CADSyncResponseCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// PSCore implementation for response details of sync
open class CADSyncResponseCore: CADSyncResponseType {

    /// Closure for decoding app specific officers
    static public var decodeOfficers: ((KeyedDecodingContainer<CADSyncResponseCore.CodingKeys>, CADSyncResponseCore.CodingKeys) throws -> [CADOfficerType])?

    // MARK: - Properties

    open var incidents: [CADIncidentType]
    open var officers: [CADOfficerType]
    open var resources: [CADResourceType]
    open var patrols: [CADPatrolType]
    open var broadcasts: [CADBroadcastType]

    // MARK: - Codable

    public enum CodingKeys: String, CodingKey {
        case incidents = "incidents"
        case officers = "officers"
        case resources = "resources"
        case patrols = "patrols"
        case broadcasts = "broadcasts"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        incidents = try values.decodeIfPresent([CADIncidentCore].self, forKey: .incidents) ?? []
        resources = try values.decodeIfPresent([CADResourceCore].self, forKey: .resources) ?? []
        patrols = try values.decodeIfPresent([CADPatrolCore].self, forKey: .patrols) ?? []
        broadcasts = try values.decodeIfPresent([CADBroadcastCore].self, forKey: .broadcasts) ?? []

        // Decode officers using injected closure with explicit type
        officers = try CADSyncResponseCore.decodeOfficers?(values, .officers) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
