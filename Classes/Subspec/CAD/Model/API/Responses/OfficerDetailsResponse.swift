//
//  OfficerDetailsResponse.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for the call to /officer/<payrollId>
public struct OfficerDetailsResponse: Codable {
    public var alias : String!
    public var firstName : String!
    public var incidentNumber : String!
    public var licenseTypeId : String!
    public var middleName : String!
    public var payrollId : String!
    public var rank : String!
    public var station : String!
    public var surname : String!
    public var zone : String!
}
