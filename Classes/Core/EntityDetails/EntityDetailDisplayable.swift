//
//  EntityDetailDisplayable.swift
//  ClientKit
//
//  Created by Bryan Hathaway on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol EntityDetailDisplayable {

    init(_ entity: MPOLKitEntity)

    var entityDisplayName: String? { get }
    var alertBadgeCount: UInt { get }
    var alertBadgeColor: UIColor? { get }
    var lastUpdatedString: String? { get }
}
