//
//  ExtensibleKey.swift
//  CoreKit
//
//  Created by Trent Fitzgibbon on 4/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Extensible 'enum' for keys that are extended in another module
///
/// Implemented the same way swift imports NS_TYPED_EXTENSIBLE_ENUMs from obj-c, but using a class instead of struct
/// to allow subclassing and with a generic type to allow different raw value implementations
open class ExtensibleKey<T>: RawRepresentable {

    // Associated type in RawRepresentable
    public typealias RawValue = T

    // Underlying raw value
    public var rawValue: T

    public required init(rawValue: T) {
        self.rawValue = rawValue
    }

    public convenience init(_ rawValue: T) {
        self.init(rawValue: rawValue)
    }
}

extension ExtensibleKey: Hashable where T: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

extension ExtensibleKey: Equatable where T: Equatable {
    public static func == (lhs: ExtensibleKey, rhs: ExtensibleKey) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
