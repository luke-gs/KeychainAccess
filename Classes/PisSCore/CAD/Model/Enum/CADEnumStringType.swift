//
//  CADEnum.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for string based enum definition that can be provided outside of MPOLKit
public protocol CADEnumStringType {

    // MARK: - Raw value

    // Enum init
    init?(rawValue: String)

    /// Enum raw value
    var rawValue: String { get }
}

/// Equality check without conforming to Equatable, to prevent need for type erasure
public func ==(lhs: CADEnumStringType?, rhs: CADEnumStringType?) -> Bool {
    return lhs?.rawValue == rhs?.rawValue
}

/// Inquality check (required when not using Equatable)
public func !=(lhs: CADEnumStringType?, rhs: CADEnumStringType?) -> Bool {
    return !(lhs?.rawValue == rhs?.rawValue)
}
