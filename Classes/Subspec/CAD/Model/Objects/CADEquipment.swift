//
//  CADEquipment.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADEquipment {
    var count: Int! { get }
    var description: String! { get }

    init(count: Int!, description: String!)
    init(equipment: CADEquipment)
}
