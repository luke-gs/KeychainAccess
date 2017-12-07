# Promise Cancelllation

By default, PromiseKit doesn't support cancellation. To quote the PromiseKit documentation.

> Promises don’t have a cancel function because you don’t want code outside of your control to be able to cancel your operations unless you explicitly want that. In cases where you want it, then it varies how it should work depending on how the underlying task supports cancellation. Thus we have provided primitives but not concrete API.

So the way that it's going to be supported in MPOLKit framework will be through `PromiseCancellationToken`. Any methods in MPOLKit that can support cancellation will declare itself as such explicitly by taking `PromiseCancellingToken` as parameter, and it will then utilise the token to cancel the underlying task.

It's recommended that the method should make the `PromiseCancellationToken` optional and provide default value of `nil`. In case of the caller doesn't care about cancellation in particular, it won't pollute the call site with unnecessary clutter. 

## Sample Usage

Sample usage:

    
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
    