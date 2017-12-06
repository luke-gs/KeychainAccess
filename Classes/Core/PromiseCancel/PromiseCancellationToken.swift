//
//  PromiseCancellationToken.swift
//  MPOLKit
//
//  Created by Herli Halim on 28/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/**
Concrete implementation of PromiseCancelling. The cancellable operation
will provide its custom cancellation code inside the `cancelAction` closure.

Sample usage:

    func fetchData(with url: URL) -> CancellablePromise<Data> {

        var dataTask: URLSessionDataTask?
        let (promise, fulfill, reject) = Promise<Data>.pending()

        // Inside the `cancelAction` closure, cancel the underlying
        // asynchronous task.
        let token = PromiseCancellationToken {
            guard let dataTask = dataTask else {
                return
            }
            dataTask.cancel()
        }

        dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // On the completion of the asynchronous task, to maintain consistency,
            // check whether the token has been cancelled, in case the cancellation request
            // didn't come in time for the underlying task to be cancelled.
            if token.isCancelled {
                reject(NSError.cancelledError())
            } else {
                if let data = data {
                    fulfill(data)
                } else if let error = error {
                    reject(error)
                }
            }
        }
        dataTask?.resume()

        return (promise, token)
    }
*/
public class PromiseCancellationToken: PromiseCancelling {

    public var isCancelled: Bool = false
    public let cancelAction: () -> Void

    public init(action: @escaping () -> Void) {
        self.cancelAction = action
    }

    public func cancel() {
        guard !isCancelled else {
            return
        }
        isCancelled = true
        cancelAction()
    }

}

public protocol CancelCommandType {
    func cancel()
}

public class CancellationToken: PromiseCancelling {

    private var mutex = pthread_mutex_t()
    private var _isCancelled = false

    private var cancelCommands = [CancelCommandType]()

    public var isCancelled: Bool {
        return _isCancelled
    }

    public init() {
        var attribute = pthread_mutexattr_t()

        guard pthread_mutexattr_init(&attribute) == 0 else {
            preconditionFailure()
        }

        pthread_mutexattr_settype(&attribute, Int32(PTHREAD_MUTEX_NORMAL))

        guard pthread_mutex_init(&mutex, &attribute) == 0 else {
            preconditionFailure()
        }

        pthread_mutexattr_destroy(&attribute)
    }

    public func addCancelCommand(_ cancelCommand: CancelCommandType) {
        pthread_mutex_lock(&mutex)

        defer {
            pthread_mutex_unlock(&mutex)
        }

        guard !_isCancelled else {
            return
        }
        cancelCommands.append(cancelCommand)
    }

    public func cancel() {

        pthread_mutex_lock(&mutex)

        defer {
            pthread_mutex_unlock(&mutex)
        }

        guard !_isCancelled else {
            return
        }
        _isCancelled = true
        for command in cancelCommands {
            command.cancel()
        }
    }

}

public struct ClosureCancelCommand: CancelCommandType {

    public let cancelAction: () -> Void

    public init(action: @escaping () -> Void) {
        self.cancelAction = action
    }

    public func cancel() {
        cancelAction()
    }

}
