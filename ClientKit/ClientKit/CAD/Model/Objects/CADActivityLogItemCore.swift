//
//  CADActivityLogItemCore.swift
//  ClientKit
//
//  Created by Kyle May on 3/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// PSCore implementation of class representing an activity log item
open class CADActivityLogItemCore: Codable, CADActivityLogItemType {

    // MARK: - Network

    open var description: String?

    open var source: String?

    open var timestamp: Date

    open var title: String?

    // MARK: - Generated
    
    open var color: UIColor {
        switch source ?? "" {
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
        timestamp = try values.decode(Date.self, forKey: .timestamp)
        title = try values.decodeIfPresent(String.self, forKey: .title)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
