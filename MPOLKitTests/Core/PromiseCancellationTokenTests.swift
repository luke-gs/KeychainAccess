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

        let token = PromiseCancellationToken()
        let promise = generatePromise(cancelToken: token)

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

    func testCancellationTokenCommandIsExecuted() {
        let cancelExpectation = expectation(description: "testCancellationTokenCommandIsExecuted")

        let token = PromiseCancellationToken()

        var actuallyCancelled = false
        token.addCancelCommand(ClosureCancelCommand {
            actuallyCancelled = true
        })

        let promise = generatePromise(cancelToken: token)

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
        XCTAssertTrue(actuallyCancelled)
    }

    func testAddingCommandAfterCancelledNotExecuted() {
        let cancelExpectation = expectation(description: "testAddingCommandAfterCancelledNotExecuted")

        let token = PromiseCancellationToken()

        let promise = generatePromise(cancelToken: token)

        promise.then { _ -> Void in
            XCTAssert(false, "This operation should be cancelled and should never reach the `.then`.")
            return ()
            }.catch(policy: .allErrors) { error in
                XCTAssert(error.isCancelledError, "Error is not due to cancellation.")
                cancelExpectation.fulfill()
        }

        var actuallyCancelled = false
        // Cancel first
        token.cancel()
        // Add the command, this shouldn't be executed.
        token.addCancelCommand(ClosureCancelCommand {
            actuallyCancelled = true
        })

        waitForExpectations(timeout: 15000, handler: nil)
        XCTAssertFalse(actuallyCancelled)
    }

    func testCancellingTwiceNotTriggeringMultipleCancelCommandsMultipleTimes() {
        let cancelExpectation = expectation(description: "testCancellingTwiceNotTriggeringMultipleCancelCommandsMultipleTimes")

        let token = PromiseCancellationToken()

        var cancelledCount = 0
        // Add the command, this shouldn't be executed.
        token.addCancelCommand(ClosureCancelCommand {
            cancelledCount += 1
        })

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2, execute: {
            token.cancel()
            token.cancel()
        })

        let promise = generatePromise(cancelToken: token)

        promise.then { _ -> Void in
            XCTAssert(false, "This operation should be cancelled and should never reach the `.then`.")
            return ()
            }.catch(policy: .allErrors) { error in
                XCTAssert(error.isCancelledError, "Error is not due to cancellation.")
                cancelExpectation.fulfill()
        }

        waitForExpectations(timeout: 15000, handler: nil)
        XCTAssertEqual(cancelledCount, 1)
    }

    func generatePromise(cancelToken: PromiseCancellationToken? = nil) -> Promise<Int> {

        let (promise, fulfill, reject) = Promise<Int>.pending()

        DispatchQueue.global().async {
            var total: Int = 0
            for i in 0 ..< 50 {
                if let token = cancelToken, token.isCancelled {
                    reject(NSError.cancelledError())
                    return
                }
                sleep(1)
                total += i
            }
            fulfill(total)
        }

        return promise

    }
}


