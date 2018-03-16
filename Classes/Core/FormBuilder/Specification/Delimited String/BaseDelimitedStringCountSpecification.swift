//
//  BaseDelimitedStringCountSpecification.swift
//  MPOLKit
//
//  Created by Kyle May on 16/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// An 'abstract' class for a count specification on delimited strings.
/// This must be subclassed with `isSatisfiedBy` overriden
open class BaseDelimitedStringCountSpecification: Specification {
    open var separator: Character
    
    private var minCount: Int?
    private var maxCount: Int?
    
    public init(separator: Character) {
        self.separator = separator
    }
    
    public init(min: Int, separator: Character) {
        self.separator = separator
        self.minCount = min
    }
    
    public init(max: Int, separator: Character) {
        self.separator = separator
        self.maxCount = max
    }
    
    public init(betweenMin min: Int, max: Int, separator: Character) {
        self.separator = separator
        self.minCount = min
        self.maxCount = max
    }
    
    public init(exactly: Int, separator: Character) {
        self.separator = separator
        self.minCount = exactly
        self.maxCount = exactly
    }
    
    open func isSatisfiedBy(_ candidate: Any?) -> Bool {
        MPLRequiresConcreteImplementation()
    }
    
    open func isValidCount(_ count: Int) -> Bool {
        switch (minCount, maxCount) {
        case (.some(let min), .some(let max)):
            return (count >= min) && (count <= max)
        case (.some(let min), _):
            return (count >= min)
        case (_, .some(let max)):
            return (count <= max)
        default:
            return false
        }
    }

}
