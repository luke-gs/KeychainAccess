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
    var count: Int { get set }
    var description: String { get set }

    // MARK: - Init

    /// Default constructor
    init(count: Int, description: String)

    /// Copy constructor
    init(equipment: CADEquipmentType)
}
