//
//  CADIncidentInformantType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADIncidentInformantType: class {

    // MARK: - Network
    var fullName : String! { get }
    var primaryPhone : String! { get }
    var secondaryPhone : String! { get }
}
