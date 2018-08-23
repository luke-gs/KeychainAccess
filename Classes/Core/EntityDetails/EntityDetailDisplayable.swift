//
//  EntityDetailDisplayable.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A Displayable used in the Entity Details screen
public protocol EntityDetailDisplayable {

    /// Intialise it with an entity
    ///
    /// - Parameter entity: The entity
    init(_ entity: MPOLKitEntity)

    /// Entity display name used in the header
    var entityDisplayName: String? { get }

    /// Used on the details dataSource sideabar count
    var alertBadgeCount: UInt? { get }

    /// Used on the details dataSource sideabar colour
    var alertBadgeColor: UIColor? { get }

    /// Used in the header somewhere
    var lastUpdatedString: String? { get }
}
