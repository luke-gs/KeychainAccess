//
//  SyncDetailsActivityLogItem.swift
//  MPOLKit
//
//  Created by Kyle May on 3/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Response object for a single activity log item in an incident (narrative) or resource
open class SyncDetailsActivityLogItem: Codable {
    open var title: String!
    open var description: String!
    open var source: String!
    open var timestamp: Date!
}
