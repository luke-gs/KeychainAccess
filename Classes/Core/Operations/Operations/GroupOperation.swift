//
//  GroupOperation.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// A subclass of `Operation` that executes zero or more operations as part of its
/// own execution. This class of operation is very useful for abstracting several
/// smaller operations into a larger operation.
///
/// Additionally, `GroupOperation`s are useful if you establish a chain of dependencies,
/// but part of the chain may "loop". For example, if you have an operation that
/// requires the user to be authenticated, you may consider putting the "login"
/// operation inside a group operation. That way, the "login" operation may produce
/// subsequent operations (still within the outer `GroupOperation`) that will all
/// be executed before the rest of the operations in the initial chain of operations.
open class GroupOperation: Operation, OperationQueueDelegate  {
    
    // MARK: - Private properties
    
    private let internalQueue = OperationQueue()
    
    /// A private operation for tracking the start of the group operation.
    ///
    /// This operation should be a dependent of all operations in the group.
    private let startingOperation = Foundation.BlockOperation(block: {})
    
    /// A private operation for tracking the end of the group operation.
    ///
    /// This operation should depend on all operations to complete prior to it executing.
    private let finishingOperation = Foundation.BlockOperation(block: {})
    
    /// The errors aggregated through all the
    private var aggregatedErrors = [NSError]()
    
    
    // MARK: - Initializers
    
    public init(operations: [Foundation.Operation]) {
        super.init()
        
        internalQueue.delegate = self
        internalQueue.isSuspended = true
        internalQueue.addOperation(startingOperation)
        
        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
    
    public convenience init(operations: Foundation.Operation...) {
        self.init(operations: operations)
    }
    
    
    // MARK: - Events and actions
    
    /// Adds an additional operation to the group.
    ///
    /// You can add an operation at any time until all operations have been completed.
    /// This allows creating additional operations in response to events within the
    /// group. You should be careful to avoid adding new operations after this time.
    /// At that stage, the behaviour is undefined.
    ///
    /// - Parameter operation: An operation to add to the queue.
    open func addOperation(operation: Foundation.Operation) {
        assert(finishingOperation.isFinished == false && finishingOperation.isExecuting == false,
               "You cannot add new operations to a GroupOperation after the group has completed.")
        
        internalQueue.addOperation(operation)
    }
    
    open override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    open override func execute() {
        internalQueue.isSuspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    
    open func operationDidFinish(_ operation: Foundation.Operation, with errors: [NSError]) {
        // For use by subclassers.
    }
    
    
    /// Notes that some part of the execution has produced an error.
    ///
    /// Errors aggregated through this method will be included in the final array
    /// of errors reported to observers, and to the `finished(_:)` method.
    ///
    /// - Note: You should only add errors that aren't generated by the child operations
    ///   as part of their execution. They are automatically handled by the
    ///   `OperationQueueDelegate` methods.
    ///
    /// - Parameter error: An error to add to the aggregated error list.
    public final func aggregateError(error: NSError) {
        aggregatedErrors.append(error)
    }
    
    
    // MARK: - OperationQueueDelegate methods
    
    public final func operationQueue(_ operationQueue: OperationQueue, willAdd operation: Foundation.Operation) {
        
        // Some operation in this group has produced a new operation to execute.
        // We want to allow that operation to execute before the group completes,
        // so we'll make the finishing operation dependent on this newly-produced operation.
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }
        
        // All operations should be dependent on the "startingOperation".
        // This way, we can guarantee that the conditions for other operations
        // will not evaluate until just before the operation is about to run.
        // Otherwise, the conditions could be evaluated at any time, even
        // before the internal operation queue is unsuspended.
        if operation !== startingOperation {
            operation.addDependency(startingOperation)
        }
    }
    
    public final func operationQueue(_ operationQueue: OperationQueue, operationDidFinish operation: Foundation.Operation, with errors: [NSError]) {
        
        aggregatedErrors.append(contentsOf: errors)
        
        if operation === finishingOperation {
            internalQueue.isSuspended = true
            finish(with: aggregatedErrors)
        } else if operation !== startingOperation {
            operationDidFinish(operation, with: errors)
        }
    }
    
}
