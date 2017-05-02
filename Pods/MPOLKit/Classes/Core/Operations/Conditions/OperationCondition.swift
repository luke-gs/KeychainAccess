//
//  OperationCondition.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


let OperationConditionKey = "OperationCondition"

/// A protocol for defining conditions that must be satisfied in order for an
/// operation to begin execution.
public protocol OperationCondition {
    
    /// The name of the condition.
    ///
    /// This is used in userInfo dictionaries of `.conditionFailed`
    /// errors as the value of the `OperationConditionKey` key.
    static var name: String { get }
    
    
    /// Specifies whether multiple instances of the conditionalized operation may
    /// be executing simultaneously.
    static var isMutuallyExclusive: Bool { get }
    
    
    /// Some conditions may have the ability to satisfy the condition if another
    /// operation is executed first. Use this method to return an operation that
    /// (for example) asks for permission to perform the operation
    ///
    /// - Parameter operation: The `Operation` to which the Condition has been added.
    /// - Returns: A `Foundation.Operation`, if a dependency should be automatically added.
    ///            Otherwise, `nil`.
    /// - Note:    Only a single operation may be returned as a dependency. If you
    ///            find that you need to return multiple operations, then you should be
    ///            expressing that as multiple conditions. Alternatively, you could return
    ///            a single `GroupOperation` that executes multiple operations internally.
    func dependency(for operation: Operation) -> Foundation.Operation?
    
    
    /// Evaluate the condition, to see if it has been satisfied or not.
    ///
    /// - Parameters:
    ///   - operation:  The operation to evaluate.
    ///   - completion: A completion handler to call on evaluation of condition.
    func evaluate(for operation: Operation, completion: (OperationConditionResult) -> Void)
}


/// An enum to indicate whether an `OperationCondition` was satisfied, or if it
/// failed with an error.
public enum OperationConditionResult: Equatable {
    case satisfied
    case failed(NSError)
    
    var error: NSError? {
        if case .failed(let error) = self {
            return error
        }
        
        return nil
    }
}

public func ==(lhs: OperationConditionResult, rhs: OperationConditionResult) -> Bool {
    switch (lhs, rhs) {
    case (.satisfied, .satisfied):
        return true
    case (.failed(let lError), .failed(let rError)) where lError == rError:
        return true
    default:
        return false
    }
}


// MARK: - Evaluate Conditions

struct OperationConditionEvaluator {
    
    static func evaluate(_ conditions: [OperationCondition], for operation: Operation, completion: @escaping ([NSError]) -> Void) {
        // Check conditions.
        let conditionGroup = DispatchGroup()
        
        var results = [OperationConditionResult?](repeating: nil, count: conditions.count)
        
        // Ask each condition to evaluate and store its result in the "results" array.
        for (index, condition) in conditions.enumerated() {
            conditionGroup.enter()
            condition.evaluate(for: operation) { result in
                results[index] = result
                conditionGroup.leave()
            }
        }
        
        // After all the conditions have evaluated, this block will execute.
        conditionGroup.notify(queue: .global(qos: .default)) {
            
            // Aggregate the errors that occurred, in order.
            var failures = results.flatMap { $0?.error }
            
            /*
             If any of the conditions caused this operation to be cancelled,
             check for that.
             */
            if operation.isCancelled {
                failures.append(NSError(code: .conditionFailed))
            }
            
            completion(failures)
        }
    }
}
