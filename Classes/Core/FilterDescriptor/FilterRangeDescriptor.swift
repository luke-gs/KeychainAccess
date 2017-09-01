//
//  FilterRangeDescriptor.swift
//  Pods
//
//  Created by Megan Efron on 1/9/17.
//
//

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
    
    public let keyMapper: (T) -> U?
    public let start: U?
    public let end: U?
    
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
