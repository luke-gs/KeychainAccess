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
    var givenName: String? { get set }
    var familyName: String? { get set }
    var licenceTypeId: String? { get set }
    var middleNames: String? { get set }
    var patrolGroup: String? { get set }
    var employeeNumber: String { get set }
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
