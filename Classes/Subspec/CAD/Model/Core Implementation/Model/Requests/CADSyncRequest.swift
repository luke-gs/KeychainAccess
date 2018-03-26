//
//  CADSyncRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// PSCore implementation for request details used to perform sync
open class CADSyncRequest: Codable {

    /// The org unit structure of the officer.
    open var orgUnitStructure: String?

    open var orgUnitCodes: [String]?

    /// The payrollId of the currently logged in officer on the mobile device.
    open var loggedInpayrollId: String!
    
    public init() {}
}
