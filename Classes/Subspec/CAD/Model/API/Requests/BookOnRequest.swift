//
//  BookOnRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Request object for the call to /shift/bookOn
open class BookOnRequest: Codable {

    /// The callsign of the resource to book on to.
    open var callsign: String!

    /// The current shift start time of the resource.
    open var shiftStart: Date!

    /// The current shift end time of the resource.
    open var shiftEnd: Date!

    /// The list of officers to book on
    open var officers: [SyncDetailsOfficer]!

    /// The list of equipment items for the resource.
    open var equipment: [SyncDetailsResourceEquipment]!

    /// The fleet number for the resource.
    open var fleetNumber: String!

    /// The optional remarks to populate as part of this book on.
    open var remarks: String!

    /// The driver payrolId for the resource (should be one of the officers in the officers array).
    open var driverpayrollId: String!

    /// The payrollId of the currently logged in officer on the mobile device.
    open var loggedInpayrollId: String!

    /// NOT IN API: The vehicle rego
    open var serial: String!

    /// NOT IN API: The vehicle category
    open var category: String!

    /// NOT IN API: The vehicle odometer
    open var odometer: String!

}
