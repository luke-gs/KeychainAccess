//
//  PromiseCancelling.swift
//  MPOLKit
//
//  Created by Herli Halim on 28/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PromiseKit

public typealias CancellablePromise<T> = (promise: Promise<T>, cancelToken: PromiseCancelling)

public protocol PromiseCancelling {

    // Used by the operation that is cancellable so it could check
    // before fulfilling/rejecting the Promise.
    var isCancelled: Bool { get }

    func cancel()
    
}
