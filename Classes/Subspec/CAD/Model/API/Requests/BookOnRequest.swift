//
//  BookOnRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class BookOnEquipment: Codable {

    /// NOT IN API: The equipment manifest item id
    open var equipmentId: String!

    /// The count of the item.
    open var count: String!
}

open class BookOnOfficer: Codable {

    /// NOT IN API: The officer payrollId.
    open var payrollId: String!

    /// NOT IN API: The contact number
    open var phoneNumber: String!

    /// NOT IN API: The licence type manifest item id
    open var licenceTypeId: String!

    /// NOT IN API: The capabilities of the officer, list of manifest item ids
    open var capabilities: [String]!

    /// NOT IN API: The optional remarks
    open var remarks: String!
}

/// Request object for the call to /shift/bookOn
open class BookOnRequest: Codable {

    /// The callsign of the resource to book on to.
    open var callsign: String!

    /// The shift period expressed in 00-99 hour format.
    open var shift: String!

    /// The list of officers to book on
    open var officers: [BookOnOfficer]!

    /// The list of equipment items for the resource.
    open var equipment: [BookOnEquipment]!

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
