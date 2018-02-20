//
//  CADEquipment.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing a piece of equipment
public protocol CADEquipmentType: class {

    // MARK: - Network
    var count: Int! { get }
    var description: String! { get }

    // MARK: - Init
    init(count: Int!, description: String!)
    init(equipment: CADEquipmentType)
}
