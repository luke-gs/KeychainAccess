//
//  DelimitedStringItemsCountSpecification.swift
//  MPOLKit
//
//  Created by Kyle May on 16/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Specification verifying the count of split items in a delimited string
open class DelimitedStringItemsCountSpecification: BaseDelimitedStringCountSpecification {
    
    override open func isSatisfiedBy(_ candidate: Any?) -> Bool {
        // Only verify strings
        guard let candidate = candidate as? String else {
            return false
        }
        
        // Split based on the delimiter
        let split = candidate.split(separator: separator)
        
        // Check if count of split array matches valid count
        return isValidCount(split.count)
    }
}
