//
//  Array+IfExists.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/3/17.
//
//

import Foundation

public extension Array {
    
    /// Access the `index`th element, if it exists.
    ///
    /// - Important: This API is for specific use cases where data requests can be inconsistent
    ///              with your data model, and its use should be considered carefully.
    ///              Don't use this method to avoid bugs in your code!
    ///
    /// - Complexity: O(1).
    subscript (ifExists index: Int) -> Element? {
        return (index < count && index >= 0) ? self[index] : nil
    }
    
    /// Returns nil if the array is empty, else the array itself.
    public func ifNotEmpty() -> [Iterator.Element]? {
        if self.isEmpty {
            return nil
        } else {
            return self
        }
    }
    
}

public extension Array where Iterator.Element: OptionalType {
    
    /// Removes all nil objects from the array then returns array nil if resulting
    /// array is empty, else the array itself.
    public func ifNotEmpty() -> [Iterator.Element.Wrapped]? {
        return self.removeNils().ifNotEmpty()
    }
}
