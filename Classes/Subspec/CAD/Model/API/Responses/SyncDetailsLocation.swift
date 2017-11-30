//
//  SyncDetailsLocation.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single location in the call to /sync/details
open class SyncDetailsLocation: Codable {
    open var alertLevel : Int!
    open var associatedAlertLevel : Int!
    open var country : String!
    open var fullAddress : String!
    open var latitude : Float!
    open var longitude : Float!
    open var postalCode : String!
    open var state : String!
    open var streetName : String!
    open var streetNumberFirst : String!
    open var streetType : String!
    open var suburb : String!
}
