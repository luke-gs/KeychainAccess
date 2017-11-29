//
//  BookOnRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct BookOnEquipment: Codable {

    /// NOT IN API: The equipment manifest item id
    let equipmentId: String

    /// The count of the item.
    let count: String
}

public struct BookOnOfficer: Codable {

    /// NOT IN API: The officer payrollId.
    let officerPayrollId: String

    /// NOT IN API: The contact number
    let contactNumber: String

    /// NOT IN API: The license type manifest item id
    let licenseTypeId: String

    /// NOT IN API: The capabilities of the officer, list of manifest item ids
    let capabilities: [String]?

    /// NOT IN API: The optional remarks
    let remarks: String?
}

/// Request object for the call to /shift/bookOn
public struct BookOnRequest: Codable {

    /// The callsign of the resource to book on to.
    let callsign: String

    /// The shift period expressed in 00-99 hour format.
    let shift: String

    /// The list of officers to book on
    let officers: [BookOnOfficer]

    /// The list of equipment items for the resource.
    let equipment: [BookOnEquipment]

    /// The fleet number for the resource.
    let fleetNumber: String?

    /// The optional remarks to populate as part of this book on.
    let remarks: String?

    /// The driver payrolId for the resource (should be one of the officers in the officers array).
    let driverpayrollId: String?

    /// The payrollId of the currently logged in officer on the mobile device.
    let loggedInpayrollId: String

    /// NOT IN API: The vehicle rego
    let serial: String?

    /// NOT IN API: The vehicle category
    let category: String?

    /// NOT IN API: The vehicle odometer
    let odometer: String?

}
