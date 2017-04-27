//
//  BlockObserver.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// The `BlockObserver` is a way to attach arbitrary blocks to significant events
/// in an `Operation`'s lifecycle.
struct BlockObserver: OperationObserver {
    
    // MARK: - Properties
    
    private let startHandler:   ((Operation) -> Void)?
    private let produceHandler: ((Operation, Foundation.Operation) -> Void)?
    private let finishHandler:  ((Operation, [NSError]) -> Void)?
    
    init(startHandler: ((Operation) -> Void)? = nil, produceHandler: ((Operation, Foundation.Operation) -> Void)? = nil, finishHandler: ((Operation, [NSError]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(_ operation: Operation) {
        startHandler?(operation)
    }
    
    func operation(_ operation: Operation, didProduce newOperation: Foundation.Operation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(_ operation: Operation, with errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}
