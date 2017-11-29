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
    public var equipmentId: String!

    /// The count of the item.
    public var count: String!
}

public struct BookOnOfficer: Codable {

    /// NOT IN API: The officer payrollId.
    public var payrollId: String!

    /// NOT IN API: The contact number
    public var phoneNumber: String!

    /// NOT IN API: The license type manifest item id
    public var licenseTypeId: String!

    /// NOT IN API: The capabilities of the officer, list of manifest item ids
    public var capabilities: [String]!

    /// NOT IN API: The optional remarks
    public var remarks: String!
}

/// Request object for the call to /shift/bookOn
public struct BookOnRequest: Codable {

    /// The callsign of the resource to book on to.
    public var callsign: String!

    /// The shift period expressed in 00-99 hour format.
    public var shift: String!

    /// The list of officers to book on
    public var officers: [BookOnOfficer]!

    /// The list of equipment items for the resource.
    public var equipment: [BookOnEquipment]!

    /// The fleet number for the resource.
    public var fleetNumber: String!

    /// The optional remarks to populate as part of this book on.
    public var remarks: String!

    /// The driver payrolId for the resource (should be one of the officers in the officers array).
    public var driverpayrollId: String!

    /// The payrollId of the currently logged in officer on the mobile device.
    public var loggedInpayrollId: String!

    /// NOT IN API: The vehicle rego
    public var serial: String!

    /// NOT IN API: The vehicle category
    public var category: String!

    /// NOT IN API: The vehicle odometer
    public var odometer: String!

}
