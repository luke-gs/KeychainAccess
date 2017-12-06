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
 Used as a token for Promise that's cancellable. The cancellable operation
 will provide its custom cancellation code inside the `cancelAction` closure.

 Sample usage:

    ````
    func cancellableFetchData(with url: URL, cancellationToken: PromiseCancellationToken? = nil) -> Promise<Data> {

        var dataTask: URLSessionDataTask?
        let (promise, fulfill, reject) = Promise<Data>.pending()

        cancellationToken?.addCancelCommand(ClosureCancelCommand {
            dataTask?.cancel()
            // Check if the promise has been resolved, no point of rejecting
            // if it has been completed
            if !promise.isFulfilled {
                reject(NSError.cancelledError())
            }
        })

        dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // On the completion of the asynchronous task, to maintain consistency,
            // check whether the token has been cancelled, in case the cancellation request
            // didn't come in time for the underlying task to be cancelled.

            if let token = cancellationToken, token.isCancelled, !promise.isFulfilled {
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

        return promise
    }
    ````

    ````
    func noncancellableFetchData(with url: URL) -> Promise<Data> {

        var dataTask: URLSessionDataTask?
        let (promise, fulfill, reject) = Promise<Data>.pending()

        dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                fulfill(data)
            } else if let error = error {
                reject(error)
            }
        }
        dataTask?.resume()

        return promise
    }
    ````

    ````
    func doSomeChaining() {
        let token = PromiseCancellationToken()
        let url = URL(string: "https://www.google.com")!

        cancellableFetchData(with: url, cancellationToken: token).then { data -> Promise<Data> in

            // Do something with the result.
            print(data)

            // Chain another cancellable request, pass the token along.
            let differentURL = URL(string: "https://www.apple.com")!
            return self.cancellableFetchData(with: differentURL, cancellationToken: token)
        }.then { data -> Promise<Data> in

            // Maybe actually do something with the result.
            print(data.count)

            // Chain to non cancellable request.
            return self.noncancellableFetchData(with: url)
        }.then { data -> Promise<Data> in
            return self.cancellableFetchData(with: url, cancellationToken: token)
        }.catch(policy: .allErrors) { error in
            if error.isCancelledError {
                // Working, I guess.
            }
        }
    }
    ````
}
 */
public class PromiseCancellationToken {

    private var mutex = pthread_mutex_t()
    private var _isCancelled = false

    private var cancelCommands = [CancelCommandType]()

    // Used by the operation that is cancellable so it could check
    // before fulfilling/rejecting the Promise.
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

    /// Add an instruction of how to cancel the underlying task to be executed on `cancel()`
    ///
    /// - Parameter cancelCommand: The command that will cancel its underlying task.
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


    /// Calling cancel() will cause propagate the cancel to all `CancelCommandType`.
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


/// Protocol to formally add a type of command that the `PromiseCancellationToken`
/// can use to add cancellable tasks.
public protocol CancelCommandType {
    func cancel()
}

/// Default implementation of `CancelCommandType` for convenience.
public struct ClosureCancelCommand: CancelCommandType {

    public let cancelAction: () -> Void

    public init(action: @escaping () -> Void) {
        self.cancelAction = action
    }

    public func cancel() {
        cancelAction()
    }

}
