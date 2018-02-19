//
//  SyncDetailsResponse.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for the call to /sync/details
open class SyncDetailsResponse: Codable {
    open var incidents : [CADIncidentCore]!
    open var officers : [CADOfficerCore]!
    open var resources : [CADResourceCore]!
    open var patrols : [CADPatrolCore]!
    open var broadcasts : [CADBroadcastCore]!
}
