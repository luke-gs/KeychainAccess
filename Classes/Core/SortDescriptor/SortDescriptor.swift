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

public struct SortDescriptor<T>: SortDescriptorType {
    public typealias Base = T
    
    public let isAscending: Bool
    
    private let keyMapper: (T) -> AnyComparable
    
    public init<V: Comparable>(ascending: Bool = true, key: @escaping (T) -> V?) {
        self.isAscending = ascending
        self.keyMapper = { AnyComparable(key($0)) }
    }
    
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
    
    public static func compare(_ lhs: T, _ rhs: T, sortDescriptors: [SortDescriptor<T>]) -> ComparisonResult {
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
fileprivate struct AnyComparable: Comparable {
    
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
            fatalError("_AnyPokemonBase instances can not be created. Create a subclass instance instead.")
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
