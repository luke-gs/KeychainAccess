//
//  Operation.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class Operation: Foundation.Operation {
    
    // MARK: - KVO updates
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        var keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        
        switch key {
        case "isReady",
             "isExecuting",
             "isFinished":
            keyPaths.insert(#keyPath(state))
        default:
            break
        }
        
        return keyPaths
    }
    
    
    // MARK: - State Management
    
    /// The state for the operation.
    ///
    /// This is a private implementation detail and not designed for wider exposure.
    @objc fileprivate enum State: Int, Comparable {
        
        /// The initial state of an `Operation`.
        case initialized
        
        /// The `Operation` is ready to begin evaluating conditions.
        case pending
        
        /// The `Operation` is evaluating conditions.
        case evaluatingConditions
        
        /// The `Operation`'s conditions have all been satisfied, and it is ready
        /// to execute.
        case ready
        
        /// The `Operation` is executing.
        case executing
        
        /// Execution of the `Operation` has finished, but it has not yet notified
        /// the queue of this.
        case finishing
        
        /// The `Operation` has finished executing.
        case finished
        
        
        /// Determines if a transition to a new state is valid from the current state
        ///
        /// - Parameter target: The proposed new state.
        /// - Returns: A boolean value indicating whether a transition to the new state
        //             is valid.
        func canTransition(to target: State) -> Bool {
            switch (self, target) {
            case (.initialized, .pending),
                 (.pending, .evaluatingConditions),
                 (.evaluatingConditions, .ready),
                 (.ready, .executing),
                 (.ready, .finishing),
                 (.executing, .finishing),
                 (.finishing, .finished):
                return true
            default:
                return false
            }
        }
    }
    
    
    /// Indicates that the Operation can now begin to evaluate readiness conditions,
    /// if appropriate.
    internal func willEnqueue() {
        state = .pending
    }
    
    
    /// Private storage for the `state` property that will be KVO observed.
    private var _state = State.initialized
    
    
    /// A serial access queue to guard reads and writes to the `_state` property.
    private let stateAccessQueue: DispatchQueue = DispatchQueue(label: "\(type(of: self)) state access queue")
    
    
    /// The state of the operation.
    ///
    /// This property is accessed and set via a serial dispatch queue for synchronous access.
    @objc private var state: State {
        get {
            return stateAccessQueue.sync { _state }
        }
        set(newState) {
            // It's important to note that the KVO notifications are NOT called inside the
            // serial queue access. If they were, the app would deadlock, because in the
            // middel of calling `didChangeValue(forKey:)`, the observers try to access
            // properties like 'isReady' or 'isFinished'. Since those methods also use the
            // state property, they would be blocked from returning until we end the update
            // block. It's the classic definition of a deadlock.
            
            willChangeValue(forKey: #keyPath(state))
            
            stateAccessQueue.sync {
                guard _state != .finished else {
                    return
                }
                
                assert(_state.canTransition(to: newState), "Performing invalid state transition.")
                _state = newState
            }
            
            didChangeValue(forKey: #keyPath(state))
        }
    }
    
    // Here is where we extend our definition of "readiness".
    open override var isReady: Bool {
        switch state {
            
        case .initialized:
            // If the operation has been cancelled, "isReady" should return true
            return isCancelled
            
        case .pending:
            // If the operation has been cancelled, "isReady" should return true
            guard !isCancelled else {
                return true
            }
            
            // If super isReady, conditions can be evaluated
            if super.isReady {
                evaluateConditions()
            }
            
            // Until conditions have been evaluated, "isReady" returns false
            return false
            
        case .ready:
            return super.isReady || isCancelled
        default:
            return false
        }
    }
    
    open override var isExecuting: Bool {
        return state == .executing
    }
    
    open override var isFinished: Bool {
        return state == .finished
    }
    
    /// A boolean value indicating whether the operation is running at the `userInitiated`
    /// priority level. This can be updated to track operations that are triggered by the user.
    ///
    /// Setting this to `true` updates the quality of service to `.userInitiated`. Setting to
    /// `false` updates the quality of service to `.default`.
    open var isUserInitiated: Bool {
        get {
            return qualityOfService == .userInitiated
        }
        set {
            assert(state < .executing, "Cannot modify userInitiated after execution has begun.")
            qualityOfService = newValue ? .userInitiated : .default
        }
    }
    
    
    private func evaluateConditions() {
        assert(state == .pending && !isCancelled, "evaluateConditions() was called out-of-order")
        
        state = .evaluatingConditions
        
        OperationConditionEvaluator.evaluate(conditions, for: self) { failures in
            self.internalErrors.append(contentsOf: failures)
            self.state = .ready
        }
    }
    
    
    // MARK: - Observers and Conditions
    
    private(set) var conditions = [OperationCondition]()
    
    open func addCondition(_ condition: OperationCondition) {
        assert(state < .evaluatingConditions, "Cannot modify conditions after execution has begun.")
        
        conditions.append(condition)
    }
    
    open private(set) var observers = [OperationObserver]()
    
    open func addObserver(_ observer: OperationObserver) {
        assert(state < .executing, "Cannot modify observers after execution has begun.")
        
        observers.append(observer)
    }
    
    open override func addDependency(_ operation: Foundation.Operation) {
        assert(state < .executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(operation)
    }
    
    
    // MARK: - Execution and Cancellation
    
    
    /// `Operation` overrides `start()` to handle if the operation was cancelled and ensure it
    /// moves into the finished state.
    ///
    /// This method is `final` and cannont be overriden. `Operation` subclasses should instead
    /// override `execute()` to handle their work and ensure they call `finish()` when their
    /// work is completed.
    public override final func start() {
        // NSOperation.start() contains important logic that shouldn't be bypassed.
        super.start()
        
        // If the operation has been cancelled, we still need to enter the "Finished" state.
        if isCancelled {
            finish()
        }
    }
    
    
    /// `Operation` overrides `main()` to run its internal logic and perform state management.
    ///
    /// This method is `final` and cannont be overriden. `Operation` subclasses should instead
    /// override `execute()` and ensure they call `finish()` when their work is completed.
    public override final func main() {
        assert(state == .ready, "This operation must be performed on an operation queue.")
        
        if internalErrors.isEmpty && !isCancelled {
            state = .executing
            
            for observer in observers {
                observer.operationDidStart(self)
            }
            
            execute()
        }
        else {
            finish()
        }
    }
    
    
    /// `execute()` is the entry point of execution for all `Operation` subclasses.
    /// If you subclass `Operation` and wish to customize its execution, you would
    /// do so by overriding the `execute()` method. You should not call `super`.
    ///
    /// At some point, your `Operation` subclass must call one of the "finish"
    /// methods defined below; this is how you indicate that your operation has
    /// finished its execution, and that operations dependent on yours can re-evaluate
    /// their readiness state.
    open func execute() {
        print("\(type(of: self)) must override `execute()`.")
        
        finish()
    }
    
    
    /// Called when a subclass produces an operation, eg an alert, associated with this
    /// base operation.
    ///
    /// - Parameter operation: The operation produces by this operation.
    public final func produceOperation(operation: Foundation.Operation) {
        for observer in observers {
            observer.operation(self, didProduce: operation)
        }
    }
    
    
    /// Cancels the current operation with an optional error.
    ///
    /// - Parameter error: An optional error parameter.
    open func cancel(with error: NSError?) {
        if let error = error {
            internalErrors.append(error)
        }
        
        cancel()
    }
    
    
    // MARK: - Finishing
    
    
    /// A private array of internal errors caught during the progress of the operation.
    private var internalErrors = [NSError]()
    
    
    /// A private property to ensure we only notify the observers once that the
    /// operation has finished.
    private var hasFinishedAlready = false
    
    
    /// A convenience function for finishing an operation with one optional error.
    @objc(finishWithError:) final func finish(with error: NSError?) {
        if let error = error {
            finish(with: [error])
        } else {
            finish()
        }
    }
    
    
    /// Called by subclasses when they finish, optionally with any errors encountered
    /// during execution.
    ///
    /// - Parameter errors: An array of errors encountered. The default is an empty array.
    @objc(finishWithErrors:) final func finish(with errors: [NSError] = []) {
        if !hasFinishedAlready {
            hasFinishedAlready = true
            state = .finishing
            
            let combinedErrors = internalErrors + errors
            finished(with: combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(self, with: combinedErrors)
            }
            
            state = .finished
        }
    }
    
    
    /// Suclasses may override `finished(with:)` if they wish to react to the operation
    /// finishing with errors. The default is a no-op.
    ///
    /// - Parameter errors: The errors produced during the operation.
    @objc(finishedWithErrors:) open func finished(with errors: [NSError]) {
        // No op.
    }
    
    
    /// `waitUntilFinished()` is highly discouraged in MPOL operations, and is considered an 
    /// anti-pattern and risks deadlocks. It is strongly recommended that you use dependent
    /// operations instead to ensure order of operation and safety. Use only as a last resort.
    open override func waitUntilFinished() {
        print("Using Operation.waitUntilFinished() is highly discouraged in MPOL Operations. See documentation on the method.")
        super.waitUntilFinished()
    }
    
    
}

// Simple operator functions to simplify the assertions used above.
fileprivate func <(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

fileprivate func ==(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
