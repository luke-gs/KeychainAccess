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

    open var count: Int!
    open var description: String!

    public required init(count: Int!, description: String!) {
        self.count = count
        self.description = description
    }

    /// Copy constructor
    public required init(equipment: CADEquipmentType) {
        self.count = equipment.count
        self.description = equipment.description
    }
}
