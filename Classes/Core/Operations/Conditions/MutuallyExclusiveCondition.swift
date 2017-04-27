//
//  MutuallyExclusiveCondition.swift
//  Pods
//
//  Created by Rod Brown on 26/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A generic condition for describing kinds of operations that may not execute concurrently.
public struct MutuallyExclusiveCondition<T>: OperationCondition {
    
    public static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }
    
    public static var isMutuallyExclusive: Bool {
        return true
    }
    
    public init() {
        // No op
    }
    
    public func dependency(for operation: Operation) -> Foundation.Operation? {
        return nil
    }
    
    public func evaluate(for operation: Operation, completion: (OperationConditionResult) -> Void) {
        completion(.satisfied)
    }
    
}
