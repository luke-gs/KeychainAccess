//
//  ISO8601DateTransformer.swift
//  MPOL
//
//  Created by Herli Halim on 4/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class ISO8601DateTransformer: OptionalTransformer {

    // Not specified anywhere whether it's thread safe, but no reason
    // to believe it's not.
    private lazy var dateFormatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
    
    // Since the underlying formatter is thread-safe, allow this
    // transformer to be shared.
    public static let shared = ISO8601DateTransformer()
    
    public func transform(_ value: String) -> Date? {
        return dateFormatter.date(from: value)
    }
    
    public func reverse(_ transformedValue: Date) -> String? {
        return dateFormatter.string(from: transformedValue)
    }
}
