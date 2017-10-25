//
//  NotNilSpecification.swift
//  MPOLKit
//
//  Created by KGWH78 on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Check if an object is not nil
public class NotNilSpecification: Specification {


    /// Check if the object is not nil
    ///
    /// - Parameter candidate: The object to be checked.
    /// - Returns: `true` if the candidate object is not nil, `false` otherwise.
    public func isSatisfiedBy(_ candidate: Any?) -> Bool {
        return candidate != nil
    }

}
