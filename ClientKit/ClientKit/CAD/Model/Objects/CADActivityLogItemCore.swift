//
//  CADActivityLogItemCore.swift
//  MPOLKit
//
//  Created by Kyle May on 3/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Response object for a single activity log item in an incident (narrative) or resource
open class CADActivityLogItemCore: Codable, CADActivityLogItemType {

    // MARK: - Network

    public var title: String!

    public var description: String!

    public var source: String!

    public var timestamp: Date!

    // MARK: - Generated
    
    open var color: UIColor {
        switch source {
        case "Duress":
            return .orangeRed
        case "Dispatch":
            return .disabledGray
        default:
            return .primaryGray
        }
    }

    // MARK: - Init

    public init(title: String!, description: String!, source: String!, timestamp: Date!) {
        self.title = title
        self.description = description
        self.source = source
        self.timestamp = timestamp
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case descriptionField = "description"
        case source = "source"
        case timestamp = "timestamp"
        case title = "title"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        description = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        source = try values.decodeIfPresent(String.self, forKey: .source)
        timestamp = try values.decodeIfPresent(Date.self, forKey: .timestamp)
        title = try values.decodeIfPresent(String.self, forKey: .title)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
