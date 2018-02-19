//
//  SyncDetailsEquipment.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// Reponse object for a single Equipment item in the resource
open class SyncDetailsEquipment: Codable, CADEquipmentType {

    // MARK: - Network

    open var count: Int!

    open var description: String!

    // MARK: - Init

    public required init(count: Int!, description: String!) {
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
        case description = "description"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        description = try values.decodeIfPresent(String.self, forKey: .description)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
