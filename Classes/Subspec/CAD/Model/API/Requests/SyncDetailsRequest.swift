//
//  SyncDetailsRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Request object for the call to /sync/details
public struct SyncDetailsRequest: Codable {

    /// The org unit structure of the officer.
    public var orgUnitStructure: String?

    public var orgUnitCodes: [String]?

    /// The payrollId of the currently logged in officer on the mobile device.
    public var loggedInpayrollId: String!
}
