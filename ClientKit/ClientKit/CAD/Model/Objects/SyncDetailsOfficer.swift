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
open class SyncDetailsOfficer: Codable {
    open var payrollId: String!
    open var rank: String!
    open var firstName: String!
    open var middleName: String!
    open var lastName: String!
    open var patrolGroup: String!
    open var station: String!
    open var licenceTypeId: String!
    open var contactNumber: String!
    open var remarks: String!
    open var capabilities: [String]!
    open var radioId: String?

    /// Default constructor
    public init() { }

    /// Copy constructor
    public init(officer: SyncDetailsOfficer) {
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


}
