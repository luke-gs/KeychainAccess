//
//  CADAssociationType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing an incident association
public protocol CADAssociationType {

    // MARK: - Network
    var id: String? { get }
    var source: String? { get }
    var entityType: String? { get }
}
