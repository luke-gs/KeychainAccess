//
//  OperationObserver.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol OperationObserver {
    
    /// Invoked immediately prior to the `Operation`'s `execute()` method.
    ///
    /// - Parameter operation: The operation that is about to start.
    func operationDidStart(_ operation: Operation)
    
    /// Invoked when `Operation.produceOperation(_:)` is executed.
    ///
    /// - Parameters:
    ///   - operation:    The base operation that created a new operation.
    ///   - newOperation: The newly created operation.
    func operation(_ operation: Operation, didProduce newOperation: Foundation.Operation)
    
    /// Invoked as an `Operation` finishes, along with any errors produced during
    /// execution (or readiness evaluation).
    ///
    /// - Parameters:
    ///   - operation: The operation that finished
    ///   - errors:    An array of errors which were produced during execution.
    func operationDidFinish(_ operation: Operation, with errors: [NSError])
    
}
