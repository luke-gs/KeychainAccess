//
//  ISO8601DateTransformer.swift
//  MPOL
//
//  Created by Herli Halim on 4/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
public class ISO8601DateTransformer: OptionalTransformer {
    
    private let dateFormatter = ISO8601DateFormatter()
    
    public func transform(_ value: String) -> Date? {
        return dateFormatter.date(from:value)
    }
    
    public func reverse(_ transformedValue: Date) -> String? {
        return dateFormatter.string(from: transformedValue)
    }
}
