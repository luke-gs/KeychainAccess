//
//  SortDescriptor.swift
//  MPOLKit
//
//  Created by Herli Halim on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol SortDescriptorType {
    associatedtype Base
}

// This is re-implemented due to some of the `Swift` value types are not visible by Objective-C runtime, causing KeyPath querying to fail.
public struct SortDescriptor<T>: SortDescriptorType {
    public typealias Base = T
    
    public let isAscending: Bool
    
    private let keyMapper: (T) -> AnyComparable

    /// Returns a SortDescriptor object initialised with the sort order and a closure property that returns the value to be sorted by.
    /// The value returned from closure must conform to `Comparable`.
    ///
    /// - Parameters:
    ///   - ascending: `true` if the sorting in ascending order, otherwise `false`.
    ///   - key: A Closure that returns value to be sorted by.
    /// - Returns: SortDescriptor initialised with the sort order specified by ascending and the property to be sorted by specified using closure.
    public init<V: Comparable>(ascending: Bool = true, key: @escaping (T) -> V?) {
        self.isAscending = ascending
        self.keyMapper = { AnyComparable(key($0)) }

    }

    /// Returns a ComparisonResult value that indicates the ordering of the two given `T`.
    ///
    /// - Parameters:
    ///   - lhs: The first `T` to compare with the second `T`.
    ///   - rhs: The second `T` to compare with the first `T`.
    /// - Returns: orderedAscending if lhs is less than rhs, orderedDescending if lhs is greater than rhs, or orderedSame if lhs is equal to rhs.
    public func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
        let result = keyMapper(lhs).compare(keyMapper(rhs))
        
        switch (isAscending, result) {
        case (true, _):
            return result
        case (false, .orderedAscending):
            return .orderedDescending
        case (false, .orderedDescending):
            return .orderedAscending
        case (false, .orderedSame):
            return .orderedSame
        }

    }

    fileprivate static func compare(_ lhs: T, _ rhs: T, sortDescriptors: [SortDescriptor<T>]) -> ComparisonResult {
        for sortDescriptor in sortDescriptors {
            switch sortDescriptor.compare(lhs, rhs) {
            case .orderedAscending:
                return .orderedAscending
            case .orderedDescending:
                return .orderedDescending
            case .orderedSame:
                continue
            }
        }
        return .orderedAscending

    }
}

public extension Sequence {
    /// Return a element of sequence sorted by specified sortDescriptors. The additional descriptors are used to refine sorting when equivalent values are found.
    ///
    /// - Parameter descriptors: An array of SortDescriptors.
    /// - Returns: The element of sequence sorted as specified by sortDescriptors.
    public func sorted(using descriptors: [SortDescriptor<Iterator.Element>]) -> [Iterator.Element] {
        return sorted { return SortDescriptor.compare($0, $1, sortDescriptors: descriptors) == .orderedAscending }
    }
}

/// A type-erased Comparable.
///
/// The `AnyComparable` forwards comparison checks to an underlying comparable, hiding
/// its specific underlying type.
///
/// By wrapping `value` in AnyComparable, it's possible to store mixed-type values in collections
/// that requires `Comparable` conformance:
/// let  = [AnyComparable("Stringy"), AnyComparable(10)]
/// Although since `Comparable` normally isn't useful across different types. The purpose
/// of this `AnyComparable` is more to allow storing `Comparable` inside collections.
///
/// Supports wrapping optional by applying following comparison rule .none < .some(_) == true

// Declared as `fileprivate` due to only being used by the SortDescriptor and
// the fact that `Comparable` conformance generally is constrainted to the type.
struct AnyComparable: Comparable {
    
    private let _box: _AnyComparableBase?
    
    init<T: Comparable>(_ comparable: T?) {
        if let comparable = comparable {
            _box = _AnyComparableBox(comparable)
        } else {
            _box = nil
        }
    }
    
    func compare(_ other: AnyComparable) -> ComparisonResult {
        
        let current = _box
        let otherBox = other._box
        
        switch (current, otherBox) {
        case (.none, .none):
            return .orderedSame
        case (.some(let lhs), .some(let rhs)):
            if lhs.isEqual(rhs) {
                return .orderedSame
            }
            return lhs.isLessThan(rhs) ? .orderedAscending : .orderedDescending
        case (.none, .some(_)):
            return .orderedAscending
        case (.some(_), .none):
            return .orderedDescending
        }
    }
    
    static func <(lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        return lhs.compare(rhs) == .orderedAscending
    }
    
    static func ==(lhs: AnyComparable, rhs: AnyComparable) -> Bool {
        return lhs.compare(rhs) == .orderedSame
    }
}

// Type-erase comparable
// For example:
// https://github.com/apple/swift/blob/master/stdlib/public/core/AnyHashable.swift
fileprivate class _AnyComparableBase {
    init() {
        guard type(of: self) != _AnyComparableBase.self else {
            fatalError("_AnyComparableBase instances can not be created. Create a subclass instance instead.")
        }
    }
    
    func isLessThan(_ other: _AnyComparableBase) -> Bool {
        MPLRequiresConcreteImplementation()
    }
    
    func isEqual(_ other: _AnyComparableBase) -> Bool {
        MPLRequiresConcreteImplementation()
    }
}

fileprivate class _AnyComparableBox<T: Comparable>: _AnyComparableBase {
    
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    override func isEqual(_ other: _AnyComparableBase) -> Bool {
        if let other = other as? _AnyComparableBox<T> {
            return self.value == other.value
        }
        return false
    }
    
    override func isLessThan(_ other: _AnyComparableBase) -> Bool {
        guard let other = other as? _AnyComparableBox<T> else {
            fatalError("Comparison across type is not supported.")
        }
        return self.value < other.value
    }
}
