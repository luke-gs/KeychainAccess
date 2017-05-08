//
//  ISO8601DateTransformer+UnboxFormatter.swift
//  MPOL
//
//  Created by Herli Halim on 8/5/17.
//
//

import Unbox

/// Internal extension so `ISO8601DateTransformer` could easily be used with Unbox.
extension ISO8601DateTransformer: UnboxFormatter {
    
    public func format(unboxedValue: String) -> Date? {
        return transform(unboxedValue)
    }
    
}
