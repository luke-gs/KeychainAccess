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
    open var capabilities: String!
}
