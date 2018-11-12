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

    public var id: String

    // MARK: - Init

    public required init(id: String, count: Int) {
        self.id = id
        self.count = count
    }

    /// Copy constructor
    public required init(equipment: CADEquipmentType) {
        self.id = equipment.id
        self.count = equipment.count
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case count = "count"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        count = try values.decode(Int.self, forKey: .count)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(count, forKey: .count)
    }
}
