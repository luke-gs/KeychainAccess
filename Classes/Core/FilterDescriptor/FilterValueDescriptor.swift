//
//  FilterValueDescriptor.swift
//  Pods
//
//  Created by Megan Efron on 1/9/17.
//
//

import UIKit

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
