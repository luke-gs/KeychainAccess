//
//  EntityDetailDisplayable.swift
//  ClientKit
//
//  Created by Bryan Hathaway on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol EntityDetailDisplayable {

    var entityDisplayName: String? { get }

    var alertCount: UInt { get }

    var lastUpdatedString: String? { get }
}
