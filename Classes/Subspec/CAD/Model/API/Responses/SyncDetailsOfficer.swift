//
//  SyncDetailsOfficer.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

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
    open var capabilties: String!
}

/// Extension for utility methods
extension SyncDetailsOfficer {
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
}
