//
//  SyncDetailsResponse.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for the call to /sync/details
public struct SyncDetailsResponse: Codable {
    public var incidents : [SyncDetailsIncident]!
    public var officers : [SyncDetailsOfficer]!
    public var resources : [SyncDetailsResource]!
}
