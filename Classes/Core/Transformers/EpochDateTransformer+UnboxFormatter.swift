//
//  EpochDateTransformer+UnboxFormatter.swift
//  MPOL
//
//  Created by Herli Halim on 8/5/17.
//
//

import Unbox

/// Internal extension so `EpochDateTransformer` could easily be used with Unbox.
extension EpochDateTransformer: UnboxFormatter {
    
//    public func format(unboxedValue: Double) -> Date? {
//        return transform(unboxedValue)
//    }
    
    // Server currently sends the `timestamp` as String, not number.
    public func format(unboxedValue: String) -> Date? {
        let casted = Double(unboxedValue)
        return transform(casted)
    }
    
}
