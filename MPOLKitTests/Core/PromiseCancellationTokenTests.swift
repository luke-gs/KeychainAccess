//
//  PromiseCancellationTokenTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 1/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Foundation
import MPOLKit
import PromiseKit

class PromiseCancellationTokenTests: XCTestCase {

    func testCancellationToken() {
        let cancelExpectation = expectation(description: "testCancellation")

        let (promise, token) = generatePromise()

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2, execute: {
            token.cancel()
        })

        promise.then { _ -> Void in
            XCTAssert(false, "This operation should be cancelled and should never reach the `.then`.")
            return ()
        }.catch(policy: .allErrors) { error in
            XCTAssert(error.isCancelledError, "Error is not due to cancellation.")
            cancelExpectation.fulfill()
        }

        waitForExpectations(timeout: 15000, handler: nil)
    }

    func generatePromise() -> CancellablePromise<Int> {

        let (promise, fulfill, reject) = Promise<Int>.pending()
        let token = PromiseCancellationToken {
            reject(NSError.cancelledError())
        }

        DispatchQueue.global().async {
            var total: Int = 0
            for i in 0 ..< 50 {
                if token.isCancelled {
                    return
                }
                sleep(1)
                total += i
            }
            fulfill(total)
        }

        return (promise, token)

    }
}


