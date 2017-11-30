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
        isCancelled = true
        cancelAction()
    }

}
