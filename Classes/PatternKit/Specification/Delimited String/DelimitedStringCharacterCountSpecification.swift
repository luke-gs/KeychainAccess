//
//  DelimitedStringCharacterCountSpecification.swift
//  MPOLKit
//
//  Created by Kyle May on 16/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Specification verifying the character count for each split item in a delimited string
open class DelimitedStringCharacterCountSpecification: BaseDelimitedStringCountSpecification {
    
    override open func isSatisfiedBy(_ candidate: Any?) -> Bool {
        // Only verify strings
        guard let candidate = candidate as? String else {
            return false
        }
        
        // Split based on the delimiter
        let split = candidate.split(separator: separator)
        
        for item in split {
            // Return false as soon as an invalid count is found
            if !isValidCount(item.count) {
                return false
            }
        }
        
        // If we haven't returned by this point then the count is valid
        return true
    }
}
