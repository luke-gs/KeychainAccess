//
//  Sequence+Nils.swift
//  Pods
//
//  Created by Megan Efron on 11/9/17.
//
//

import UIKit

// Safe way to remove nils from collection
// https://stackoverflow.com/questions/28190631/creating-an-extension-to-filter-nils-from-an-array-in-swift/38548106#38548106

public protocol OptionalType {
    associatedtype Wrapped
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
}

extension Optional: OptionalType {}

public extension Sequence where Iterator.Element: OptionalType {
    public func removeNils() -> [Iterator.Element.Wrapped] {
        var result: [Iterator.Element.Wrapped] = []
        for element in self {
            if let element = element.map({ $0 }) {
                result.append(element)
            }
        }
        return result
    }
}

public extension Sequence where Iterator.Element == String? {
    public func joined(separator: String = " ") -> String {
        return removeNils().joined(separator: separator)
    }
}
