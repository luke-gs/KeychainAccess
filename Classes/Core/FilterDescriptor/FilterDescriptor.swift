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

public class FilterDescriptor<T>: FilterDescriptorType {
    public typealias Base = T
    
    public func shouldntInclude(value: T) -> Bool {
        MPLRequiresConcreteImplementation()
    }

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
