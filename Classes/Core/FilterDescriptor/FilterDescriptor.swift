//
//  FilterDescriptor.swift
//  Pods
//
//  Created by Megan Efron on 30/8/17.
//
//

import Foundation

public protocol FilterDescriptorType {
    associatedtype Base
}


/// Abstract `FilterDescriptor` is a class that defines how to filter a collection.
/// You can use the new method 'filter(using: [FilterDescriptor<T>])' on any `Sequence`
/// to filter it based on the concrete implementation of `shouldntInclude(value: T)`.
///
/// - Important: All subclasses must provide a concrete implementation of 
///              `shouldntInclude(value: T)`.
public class FilterDescriptor<T>: FilterDescriptorType {
    public typealias Base = T
    
    
    /// Abstract method that defines whether a value should or shouldn't be included in a collection
    /// based on certain conditions provided by the subclass.
    ///
    /// - Parameter value: The value being assessed for inclusion.
    /// - Returns: A boolean indicating whether the value should or shouldnt be
    ///            included (return true if it shouldn't).
    public func shouldntInclude(value: T) -> Bool {
        MPLRequiresConcreteImplementation()
    }

    
    /// A static method that evaluates whether a value should be included in a collection based on
    /// a range of descriptors that define in their own implementations of 'shouldntInclude(value: T)'.
    ///
    /// - Parameters:
    ///   - value: The value being assessed for inclusion.
    ///   - descriptors: The descriptors to compare the value against.
    /// - Returns: A boolean indicating whether the value should or shouldnt be included.
    fileprivate static func shouldInclude(value: T, descriptors: [FilterDescriptor<T>]) -> Bool {
        guard descriptors.count > 0 else { return true }
        for descriptor in descriptors {
            if descriptor.shouldntInclude(value: value) {
                return false
            }
        }
        return true
    }
}


/// This concrete implementation of 'FilterDescriptor' will filter a `Sequence` if the value
/// in question is contained by a set of provided values.
///
/// i.e. For a collection of people with a `surname` property that have surnames:
/// ````
/// ["Halim", "Aramroongrot", "Sammut", "Wang", "Shorinov", "Boryseiko"]
/// ````
/// You can provide a `FilterValueDescriptor' to filter based on `surname`:
/// ````
/// let surnameFilterDescriptor = FilterValueDescriptor<Person>(key: { $0.surname }, values: Set(["Halim", "Sammut", "Boryseiko"]))
/// let filtered = iOSGuys.filter(using: [surnameFilterDescriptor])
/// ````
public class FilterValueDescriptor<T>: FilterDescriptor<T> {
    
    fileprivate let keyMapper: (T) -> AnyHashable?
    
    fileprivate let values: Set<AnyHashable>
    
    public init(key: @escaping (T) -> AnyHashable?, values: Set<AnyHashable>) {
        self.keyMapper = key
        self.values = values
    }
    
    public override func shouldntInclude(value: T) -> Bool {
        if let value = keyMapper(value), !values.contains(value) {
            return true
        }
        return false
    }
}

/// This concrete implementation of 'FilterDescriptor' will filter a `Sequence` if the value
/// in question is contained within a range of values from `start` to `end`.
///
/// i.e. For a collection of people with an `age` property that have ages:
/// ````
/// [12, 20, 25, 42, 48, 61]
/// ````
/// You can provide a `FilterRangeDescriptor` to filter based on `age`:
/// ````
/// let ageFilterDescriptor = FilterRangeDescriptor<Person>(key: { $0.age }, start: 20, end: 50)
/// let filtered = iOSGuys.filter(using: [ageFilterDescriptor])
/// ````
///
/// Current implementation will include `start` and `finish` during filtering.
public class FilterRangeDescriptor<T>: FilterDescriptor<T> {
    
    fileprivate let keyMapper: (T) -> AnyComparable?

    fileprivate let start: AnyComparable?
    fileprivate let end: AnyComparable?

    public init<V: Comparable>(key: @escaping (T) -> V?, start: V?, end: V?) {
        self.keyMapper = { AnyComparable(key($0)) }
        self.start = AnyComparable(start)
        self.end = AnyComparable(end)
    }
    
    public override func shouldntInclude(value: T) -> Bool {
        if let value = keyMapper(value) {
            if let start = start, value < start {
                return true
            }
            if let end = end, value > end {
                return true
            }
        }
        return false
    }
}

public extension Sequence {
    public func filter(using descriptors: [FilterDescriptor<Iterator.Element>]) -> [Iterator.Element] {
        return filter { FilterDescriptor.shouldInclude(value: $0, descriptors: descriptors) }
    }
}
