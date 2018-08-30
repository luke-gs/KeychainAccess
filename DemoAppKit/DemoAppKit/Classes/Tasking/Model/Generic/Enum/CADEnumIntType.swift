//
//  CADEnumIntType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for int based enum definition that can be provided outside of MPOLKit
public protocol CADEnumIntType {

    // MARK: - Raw value

    // Enum init
    init?(rawValue: Int)

    /// Enum raw value
    var rawValue: Int { get }
}

/// Equality check without conforming to Equatable, to prevent need for type erasure
public func ==(lhs: CADEnumIntType?, rhs: CADEnumIntType?) -> Bool {
    return lhs?.rawValue == rhs?.rawValue
}

/// Inquality check (required when not using Equatable)
public func !=(lhs: CADEnumIntType?, rhs: CADEnumIntType?) -> Bool {
    return !(lhs?.rawValue == rhs?.rawValue)
}
