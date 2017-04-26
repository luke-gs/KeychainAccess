//
//  NetworkActivityObserver.swift
//  Pods
//
//  Created by Rod Brown on 27/4/17.
//
//

import Foundation

public struct NetworkObserver: OperationObserver {
    
    public init() { }
    
    
    public func operationDidStart(_ operation: Operation) {
        NetworkMonitor.shared.networkEventDidStart()
    }
    
    public func operation(_ operation: Operation, didProduce newOperation: Foundation.Operation) { }
    
    public func operationDidFinish(_ operation: Operation, with errors: [NSError]) {
        NetworkMonitor.shared.networkEventDidEnd()
    }
    
}
