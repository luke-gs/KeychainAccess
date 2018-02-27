//
//  CADBookOffDetailsType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for request details used to book off resource
public protocol CADBookOffDetailsType {

    // MARK: - Network
    var callsign: String? { get set }
    var loggedInPayrollId: String? { get set }
}
