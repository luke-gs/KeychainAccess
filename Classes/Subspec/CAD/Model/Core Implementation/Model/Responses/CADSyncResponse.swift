//
//  CADSyncResponse.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// PSCore implementation for response details of sync
open class CADSyncResponse: Codable {
    open var incidents : [CADIncidentCore]!
    open var officers : [CADOfficerCore]!
    open var resources : [CADResourceCore]!
    open var patrols : [CADPatrolCore]!
    open var broadcasts : [CADBroadcastCore]!
}
