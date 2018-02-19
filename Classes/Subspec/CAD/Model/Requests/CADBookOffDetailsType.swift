//
//  CADBookOffDetailsType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for book off details used by kit
public protocol CADBookOffDetailsType {

    // MARK: - Network
    var callsign: String! { get }
    var loggedInPayrollId: String! { get }
}
