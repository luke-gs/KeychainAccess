//
//  DispatchQueue+PerformOnMain.swift
//  MPOLKit
//
//  Created by Ryan Wu on 8/11/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import Dispatch

public extension DispatchQueue {
    
    /// Perform work that is guaranteed to occur synchronously on the main thread.
    /// When called on the main thread, this function executes the block immediately, and
    /// returns any required value. When called on another thread, the block executes
    /// on the main thread, blocking the current thread until the work is executed on the
    /// main thread, and returns to the current thread, with any return value.
    ///
    /// - Important: If you don't require synchronous behaviour, it is strongly recommended
    ///              you call `DispatchQueue.main.async()` instead, and allow the work to
    ///              occur without blocking your current thread.
    ///
    /// - Parameter block: The block containing work that requires to be executed on the main thread.
    ///
    /// - Returns:         Any returned value. This can be implied by the return type of the block,
    ///                    or explicitly declared.
    public static func performOnMain<T>(execute block: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try block()
        } else {
            return try DispatchQueue.main.sync(execute: block)
        }
    }
}
