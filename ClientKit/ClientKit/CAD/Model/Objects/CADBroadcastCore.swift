//
//  CADBroadcastCore.swift
//  ClientKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// TODO: Update this to match API when we get a spec, as this is created based on what the UI needs

/// PSCore implementation of class representing a broadcast task
open class CADBroadcastCore: Codable, CADBroadcastType {

    // MARK: - Network

    open var createdAt: Date!

    open var details: String!

    open var identifier: String!

    open var lastUpdated: Date!

    open var location: CADLocationType!

    open var title: String!

    open var type: CADBroadcastCategoryType!

    // MARK: - Generated

    open var createdAtString: String {
        return DateFormatter.preferredDateTimeStyle.string(from: createdAt)
    }

    /// Create a map annotation for the task list item if location is available
    open func createAnnotation() -> TaskAnnotation? {
        return nil
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
        location = try values.decodeIfPresent(CADLocationCore.self, forKey: .location)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        type = try values.decodeIfPresent(CADBroadcastCategoryCore.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
