//
//  EpochDateTransformer.swift
//  MPOL
//
//  Created by Herli Halim on 4/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class EpochDateTransformer: OptionalTransformer {

    public static let shared = EpochDateTransformer()
        
    public func transform(_ value: Double) -> Date? {
        return Date(timeIntervalSince1970: value)
    }
    
    public func reverse(_ transformedValue: Date) -> Double? {
        return transformedValue.timeIntervalSince1970
    }
    
}
