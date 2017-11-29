//
//  BookOffRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Request object for the call to /shift/bookOff
public struct BookOffRequest: Codable {

    /// The callsign for the resource.
    let callsign: String

    /// The payrollId of the currently logged in officer on the mobile device.
    let loggedInpayrollId: String
}
