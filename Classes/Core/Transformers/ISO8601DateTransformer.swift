//
//  ISO8601DateTransformer.swift
//  MPOL
//
//  Created by Herli Halim on 4/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class ISO8601DateTransformer: OptionalTransformer {
    
    // Thread safe since iOS 7 and above.
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // Not specified anywhere whether it's thread safe, but no reason
    // to believe it's not.
    @available(iOS 10.0, *)
    private lazy var dateFormatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
    
    // Since the underlying formatter is thread-safe, allow this
    // transformer to be shared.
    public static let shared = ISO8601DateTransformer()
    
    public func transform(_ value: String) -> Date? {
        if #available(iOS 10.0, *) {
            return dateFormatter.date(from: value)
        } else {
            return formatter.date(from: value)
        }
        
    }
    
    public func reverse(_ transformedValue: Date) -> String? {
        if #available(iOS 10.0, *) {
            return dateFormatter.string(from: transformedValue)
        } else {
            return formatter.string(from: transformedValue)
        }
    }
}
