//
//  CADBookOffRequest.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// PSCore implementation for request details used to book off a resource
open class CADBookOffRequest: Codable, CADBookOffDetailsType {

    // MARK: - Network

    /// The callsign for the resource.
    open var callsign: String?

    /// The payrollId of the currently logged in officer on the mobile device.
    open var loggedInPayrollId: String?
    
    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        MPLUnimplemented()
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
