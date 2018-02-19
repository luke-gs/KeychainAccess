//
//  SyncDetailsLocation.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single location in the call to /sync/details
open class SyncDetailsLocation: Codable, CADLocationType {

    public var alertLevel: Int?

    public var country: String!

    public var fullAddress: String!

    public var latitude: Float!

    public var longitude: Float!

    public var postalCode: String!

    public var state: String!

    public var streetName: String!

    public var streetNumberFirst: String!

    public var streetNumberLast: String!

    public var streetType: String!

    public var suburb: String!

}
