//
//  CADOfficer.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing an officer
public protocol CADOfficerType: class {

    // MARK: - Network
    var capabilities: [String] { get set }
    var contactNumber: String? { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var licenceTypeId: String? { get set }
    var middleName: String? { get set }
    var patrolGroup: String? { get set }
    var payrollId: String { get set }
    var radioId: String? { get set }
    var rank: String? { get set }
    var remarks: String? { get set }
    var station: String? { get set }

    // MARK: - Generated
    var displayName: String { get }
    var initials: String? { get }
    var payrollIdDisplayString: String { get }

    // MARK: - Init

    /// Default constructor
    init()

    /// Copy constructor
    init(officer: CADOfficerType)
}
