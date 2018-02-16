//
//  CADBookOffDetailsType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADBookOffDetailsType {

    /// The callsign for the resource.
    var callsign: String! { get }

    /// The payrollId of the currently logged in officer on the mobile device.
    var loggedInPayrollId: String! { get }

}
