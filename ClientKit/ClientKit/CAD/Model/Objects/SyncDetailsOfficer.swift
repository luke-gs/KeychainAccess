//
//  SyncDetailsOfficer.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single Officer in the call to /sync/details
open class SyncDetailsOfficer: Codable, CADOfficerType {

    // MARK: - Network
    public var capabilities: [String]!

    public var contactNumber: String!

    public var firstName: String!

    public var lastName: String!

    public var licenceTypeId: String!

    public var middleName: String!

    public var patrolGroup: String!

    public var payrollId: String!

    public var radioId: String?

    public var rank: String!

    public var remarks: String!

    public var station: String!

    // MARK: - Generated

    open var displayName: String {
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName
        nameComponents.middleName = middleName
        nameComponents.familyName = lastName
        return OfficerDetailsResponse.nameFormatter.string(from: nameComponents)
    }

    open static var nameFormatter: PersonNameComponentsFormatter = {
        let nameFormatter = PersonNameComponentsFormatter()
        nameFormatter.style = .medium
        return nameFormatter
    }()

    open var payrollIdDisplayString: String? {
        if let payrollId = payrollId {
            return "#\(payrollId)"
        }
        return nil
    }

    open var initials: String {
        return [String(firstName?.prefix(1)), String(lastName?.prefix(1))].joined(separator: "")
    }

    // MARK: - Init

    /// Default constructor
    public required init() { }

    /// Copy constructor
    public required init(officer: CADOfficerType) {
        self.payrollId = officer.payrollId
        self.rank = officer.rank
        self.firstName = officer.firstName
        self.middleName = officer.middleName
        self.lastName = officer.lastName
        self.patrolGroup = officer.patrolGroup
        self.station = officer.station
        self.licenceTypeId = officer.licenceTypeId
        self.contactNumber = officer.contactNumber
        self.remarks = officer.remarks
        self.capabilities = officer.capabilities
        self.radioId = officer.radioId
    }

}
