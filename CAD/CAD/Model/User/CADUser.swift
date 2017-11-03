//
//  CADUser.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 3/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// CAD specific user
open class CADUser: User {

    /// App key for per app user settings
    override open var applicationKey: String {
        return "CAD"
    }
}
