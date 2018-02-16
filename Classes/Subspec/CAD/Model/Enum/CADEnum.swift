//
//  CADEnum.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for base CAD enum definition that can be provided in Client Kit
public protocol CADEnumType {

    // MARK: - Init

    // Expose enum init
    init?(rawValue: String)

    /// Expose enum raw value
    var rawValue: String { get }
}

/// Equality check without conforming to Equatable, to prevent need for type erasure
func ==(lhs: CADEnumType?, rhs: CADEnumType?) -> Bool {
    return lhs?.rawValue == rhs?.rawValue
}

/// Inquality check (required when not using Equatable)
func !=(lhs: CADEnumType?, rhs: CADEnumType?) -> Bool {
    return !(lhs?.rawValue == rhs?.rawValue)
}
