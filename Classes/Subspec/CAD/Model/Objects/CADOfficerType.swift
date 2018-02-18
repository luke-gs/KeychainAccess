//
//  CADOfficer.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol CADOfficerType {
    static var nameFormatter: PersonNameComponentsFormatter { get }

    var payrollId: String! { get set }
    var rank: String! { get set }
    var firstName: String! { get set }
    var middleName: String! { get set }
    var lastName: String! { get set }
    var patrolGroup: String! { get set }
    var station: String! { get set }
    var licenceTypeId: String! { get set }
    var contactNumber: String! { get set }
    var remarks: String! { get set }
    var capabilities: [String]! { get set }
    var radioId: String? { get set }

    var displayName: String { get }
    var payrollIdDisplayString: String? { get }
    var initials: String { get }

    // Default constructor
    init()

    /// Copy constructor
    init(officer: CADOfficerType)
}
