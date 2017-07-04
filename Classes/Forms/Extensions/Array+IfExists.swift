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
        return index < count ? self[index] : nil
    }
    
}
