//
//  Foundation.Operation+MPOLAdditions.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension Foundation.Operation {
    
    /// Adds a completion block to be called after the `Operation` enters the "finished"
    /// state. This block will be called after all others that have previously been set.
    ///
    /// - Parameter block: A new block to execute on completion.
    public func addCompletionBlock(_ block: @escaping () -> Void) {
        if let existing = completionBlock {
            /*
             If we already have a completion block, we construct a new one by
             chaining them together.
             */
            completionBlock = {
                existing()
                block()
            }
        } else {
            completionBlock = block
        }
    }
    
    
    /// A convenience method to add multiple dependent operations to the operation.
    ///
    /// - Parameter dependencies: An array of operations to make dependent on this operation.
    public func addDependencies(_ dependencies: [Foundation.Operation]) {
        for dependency in dependencies {
            addDependency(dependency)
        }
    }
    
}
