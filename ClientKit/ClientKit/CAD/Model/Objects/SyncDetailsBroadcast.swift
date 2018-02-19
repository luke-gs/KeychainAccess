//
//  SyncDetailsBroadcast.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// TODO: Update this to match API when we get a spec, as this is created based on what the UI needs

open class SyncDetailsBroadcast: Codable, CADBroadcastType {

    // MARK: - Network

    public var createdAt: Date!

    public var details: String!

    public var identifier: String!

    public var lastUpdated: Date!

    public var location: CADLocationType!

    public var title: String!

    public var type: String!

    // MARK: - Generated

    open var createdAtString: String {
        return DateFormatter.preferredDateTimeStyle.string(from: createdAt)
    }

    /// Type as an enum defined in protocol
    open var categoryType: CADBroadcastCategoryType {
        get {
            return CADClientModelTypes.broadcastCategory.init(rawValue: type) ?? CADClientModelTypes.broadcastCategory.defaultCase
        }
        set {
            type = newValue.rawValue
        }
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case createdAt = "createdAt"
        case details = "details"
        case identifier = "identifier"
        case lastUpdated = "lastUpdated"
        case location = "location"
        case title = "title"
        case type = "type"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        details = try values.decodeIfPresent(String.self, forKey: .details)
        identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        lastUpdated = try values.decodeIfPresent(Date.self, forKey: .lastUpdated)
        location = try values.decodeIfPresent(SyncDetailsLocation.self, forKey: .location)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
