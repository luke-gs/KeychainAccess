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

public struct FilterDescriptor<T>: FilterDescriptorType {
    public typealias Base = T
    
    fileprivate let keyMapper: (T) -> AnyHashable?
    
    fileprivate let values: Set<AnyHashable>
    
    public init(key: @escaping (T) -> AnyHashable?, values: Set<AnyHashable>) {
        self.keyMapper = key
        self.values = values
    }
    
    fileprivate static func shouldInclude(value: T, descriptors: [FilterDescriptor<T>]) -> Bool {
        guard descriptors.count > 0 else { return true }
        
        var isIncluded = true
        for descriptor in descriptors {
            if let value = descriptor.keyMapper(value), !descriptor.values.contains(value) {
                isIncluded = false
            }
        }
        return isIncluded
    }
}

public extension Sequence {
    
    public func filter(using descriptors: [FilterDescriptor<Iterator.Element>]) -> [Iterator.Element] {
        return filter { return FilterDescriptor.shouldInclude(value: $0, descriptors: descriptors) }
    }
}
