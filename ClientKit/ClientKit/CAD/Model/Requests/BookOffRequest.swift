//
//  BookOffRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Request object for the call to /shift/bookOff
open class BookOffRequest: Codable, CADBookOffDetailsType {

    /// The callsign for the resource.
    open var callsign: String!

    /// The payrollId of the currently logged in officer on the mobile device.
    open var loggedInPayrollId: String!
}
