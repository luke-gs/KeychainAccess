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

public extension Sequence {
    public func filter(using descriptors: [FilterDescriptor<Iterator.Element>]) -> [Iterator.Element] {
        return filter { FilterDescriptor.filter(value: $0, descriptors: descriptors) }
    }
}
