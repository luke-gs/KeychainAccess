//
//  CADStateManager.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public extension NSNotification.Name {

    /// Notification posted when callsign status changes
    static let CallsignChanged = NSNotification.Name(rawValue: "CAD_CallsignChanged")
}

open class CADStateManager: NSObject {

    /// The singleton state monitor.
    open static let shared = CADStateManager()

    /// The currently booked on callsign, or nil
    open var callsign: String? {
        didSet {
            NotificationCenter.default.post(name: .CallsignChanged, object: self)
        }
    }
}
