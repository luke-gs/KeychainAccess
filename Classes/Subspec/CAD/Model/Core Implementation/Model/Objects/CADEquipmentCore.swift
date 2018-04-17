//
//  CADEquipmentCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore implementation of class representing resource equipment
open class CADEquipmentCore: Codable, CADEquipmentType {

    // MARK: - Network

    public var count: Int

    public var description: String

    // MARK: - Init

    public required init(count: Int, description: String) {
        self.count = count
        self.description = description
    }

    /// Copy constructor
    public required init(equipment: CADEquipmentType) {
        self.count = equipment.count
        self.description = equipment.description
    }
    
    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case count = "count"
        case description = "name"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decodeIfPresent(Int.self, forKey: .count) ?? 0
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(description, forKey: .description)
    }
}
