//
//  CADSyncRequest.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// PSCore implementation of patrol group sync request
open class CADSyncPatrolGroupRequestCore: CADSyncPatrolGroupRequestType {

    public init(patrolGroup: String) {
        self.patrolGroup = patrolGroup
    }

    // MARK: - Request Parameters
    
    /// The patrol group to return results for
    open var patrolGroup: String

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case patrolGroup
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(patrolGroup, forKey: CodingKeys.patrolGroup)
    }
}
