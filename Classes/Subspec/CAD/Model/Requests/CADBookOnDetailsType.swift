//
//  BookOnDetails.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADBookOnDetailsType {

    /// The callsign of the resource to book on to.
    var callsign: String! { get }

    /// The current shift start time of the resource.
    var shiftStart: Date! { get }

    /// The current shift end time of the resource.
    var shiftEnd: Date! { get }

    /// The list of officers to book on
    var officers: [CADOfficerType]! { get }

    /// The list of equipment items for the resource.
    var equipment: [CADEquipmentType]! { get }

    /// Copy constructor (deep)
    init(request: CADBookOnDetailsType)
}
