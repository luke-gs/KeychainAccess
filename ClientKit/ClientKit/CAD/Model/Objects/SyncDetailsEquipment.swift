//
//  SyncDetailsEquipment.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Reponse object for a single Equipment item in the resource
open class SyncDetailsEquipment: Codable {
    open var count: Int!
    open var description: String!

    public init(count: Int!, description: String!) {
        self.count = count
        self.description = description
    }

    /// Copy constructor
    public init(equipment: SyncDetailsEquipment) {
        self.count = equipment.count
        self.description = equipment.description
    }
}
