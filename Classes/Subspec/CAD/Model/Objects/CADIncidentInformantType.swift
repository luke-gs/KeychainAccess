//
//  CADIncidentInformantType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing an incident informant
public protocol CADIncidentInformantType: class {

    // MARK: - Network
    var fullName : String? { get set }
    var primaryPhone : String? { get set }
    var secondaryPhone : String? { get set }
}
