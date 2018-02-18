//
//  BookOnDetails.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADBookOnDetailsType: class {

    /// The callsign of the resource to book on to.
    var callsign: String! { get set }

    /// The current shift start time of the resource.
    var shiftStart: Date! { get set }

    /// The current shift end time of the resource.
    var shiftEnd: Date! { get set }

    /// The list of officers to book on
    var officers: [CADOfficerType]! { get set }

    /// The list of equipment items for the resource.
    var equipment: [CADEquipmentType]! { get set }

    /// The fleet number for the resource.
    var fleetNumber: String! { get set }

    /// The optional remarks to populate as part of this book on.
    var remarks: String! { get set }

    /// The driver payrolId for the resource (should be one of the officers in the officers array).
    var driverpayrollId: String! { get set }

    /// The payrollId of the currently logged in officer on the mobile device.
    var loggedInpayrollId: String! { get set }

    /// NOT IN API: The vehicle rego
    var serial: String! { get set }

    /// NOT IN API: The vehicle category
    var category: String! { get set }

    /// NOT IN API: The vehicle odometer
    var odometer: String! { get set }

    // Default constructor
    init()

    /// Copy constructor (deep)
    init(request: CADBookOnDetailsType)
}
