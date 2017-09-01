//
//  FilterDescriptor.swift
//  Pods
//
//  Created by Megan Efron on 30/8/17.
//
//

import Foundation


/// Base class `FilterDescriptor` is a class that defines how to filter a collection.
/// You can use the new method 'filter(using: [FilterDescriptor<T>])' on any `Sequence`
/// to filter it based on the concrete implementation of `filter(value: T)`.
///
/// - Important: All subclasses must provide a concrete implementation of 
///              `filter(value: T)`.
open class FilterDescriptor<T> {
    
    /// Abstract method that defines whether a value should be included in a collection
    /// based on certain conditions provided by the subclass.
    ///
    /// - Parameter value: The value being assessed for inclusion.
    /// - Returns: A boolean indicating whether the value should be included.
    open func filter(value: T) -> Bool {
        MPLRequiresConcreteImplementation()
    }

    /// A static method that evaluates whether a value should be included in a collection based on
    /// a range of descriptors that define in their own implementations of 'filter(value: T)'.
    ///
    /// - Parameters:
    ///   - value: The value being assessed for inclusion.
    ///   - descriptors: The descriptors to compare the value against.
    /// - Returns: A boolean indicating whether the value should or shouldnt be included.
    fileprivate static func filter(value: T, descriptors: [FilterDescriptor<T>]) -> Bool {
        guard descriptors.count > 0 else { return true }
        for descriptor in descriptors {
            if !descriptor.filter(value: value) {
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
public class FilterValueDescriptor<T, U: Hashable>: FilterDescriptor<T> {
    
    fileprivate let keyMapper: (T) -> U?
    fileprivate let values: Set<U>
    
    public init(key: @escaping (T) -> U?, values: Set<U>) {
        self.keyMapper = key
        self.values = values
    }
    
    public override func filter(value: T) -> Bool {
        if let value = keyMapper(value) {
            return values.contains(value)
        }
        return true
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
public class FilterRangeDescriptor<T, U: Comparable>: FilterDescriptor<T> {
    
    fileprivate let keyMapper: (T) -> U?
    fileprivate let start: U?
    fileprivate let end: U?

    public init(key: @escaping (T) -> U?, start: U?, end: U?) {
        self.keyMapper = { key($0) }
        self.start = start
        self.end = end
    }
    
    public override func filter(value: T) -> Bool {
        if let value = keyMapper(value) {
            if let start = start, value < start {
                return false
            }
            if let end = end, value > end {
                return false
            }
        }
        return true
    }
}

public extension Sequence {
    public func filter(using descriptors: [FilterDescriptor<Iterator.Element>]) -> [Iterator.Element] {
        return filter { FilterDescriptor.filter(value: $0, descriptors: descriptors) }
    }
}
