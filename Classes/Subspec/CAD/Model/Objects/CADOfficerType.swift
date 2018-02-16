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

    var payrollId: String! { get }
    var rank: String! { get }
    var firstName: String! { get }
    var middleName: String! { get }
    var lastName: String! { get }
    var patrolGroup: String! { get }
    var station: String! { get }
    var licenceTypeId: String! { get }
    var contactNumber: String! { get }
    var remarks: String! { get }
    var capabilities: [String]! { get }
    var radioId: String? { get }

    var displayName: String { get }
    var payrollIdDisplayString: String? { get }
    var initials: String { get }

    /// Copy constructor
    init(officer: CADOfficerType)
}
