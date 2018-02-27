//
//  DataCoordinatorTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import XCTest
import PromiseKit
@testable import MPOLKit


class DataCoordinatorTests: XCTestCase {

    func testThatItsDefaultStatesAreCorrect() {
        // Given
        let store: ReadOnlyStore = ReadOnlyStore()

        // When
        let provider = DataStoreCoordinator(dataStore: store)

        // Then
        XCTAssertEqual(provider.state, .unknown)
        XCTAssertEqual(provider.items.count, 0)
    }

    func testThatItRetrievesItems() {
        // Given
        let store = ReadOnlyStore(numbers: [1, 2, 3])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        _ = after(seconds: 0.1).then {
            XCTAssertEqual(provider.state, .loading)
        }

        provider.retrieveItems().then { newItems -> () in
            // Then
            XCTAssertEqual(provider.state, .completed)
            XCTAssertEqual(provider.items, newItems)
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItAddsItem() {
        // Given
        let store = WritableStore(numbers: [1, 2])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.addItem(3).then { _ in
            return provider.retrieveItems()
        }.then { _ -> () in
            // Then
            XCTAssertEqual(provider.items, [1, 2, 3])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItRemovesItem() {
        // Given
        let store = WritableStore(numbers: [1, 2])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.removeItem(2).then { _ in
            return provider.retrieveItems()
        }.then { _ -> () in
            // Then
            XCTAssertEqual(provider.items, [1])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItReplacesItem() {
        // Given
        let store = WritableStore(numbers: [1, 2])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.replaceItem(2, with: 3).then { _ in
            return provider.retrieveItems()
        }.then { _ -> () in
            // Then
            XCTAssertEqual(provider.items, [1, 3])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItHasMoreItemsWhenThereIsAKnownResult() {
        // Given
        let store = WritableStore(numbers: [1, 2], additionalItems: [3, 4])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveItems().then { _ -> () in
            // Then
            XCTAssertTrue(provider.hasMoreItems())
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatItDoesNotHaveMoreItemsWhenThereIsAKnownResult() {
        // Given
        let store = WritableStore(numbers: [1, 2])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveItems().then { _ -> () in
            // Then
            XCTAssertFalse(provider.hasMoreItems())
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatItDoesNotHaveMoreItemsWhenThereisNoKnownResult() {
        // Given
        let store = WritableStore(numbers: [1, 2])
        let provider = DataStoreCoordinator(dataStore: store)

        // When
        let hasMoreItems = provider.hasMoreItems()

        // Then
        XCTAssertFalse(hasMoreItems)
    }

    func testThatItRetrievesMoreItemsWhenKnownResultHasMoreItems() {
        // Given
        let store = WritableStore(numbers: [1, 2], additionalItems: [3, 4])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveItems().then { _ in
            return provider.retrieveMoreItems()
        }.then { items -> () in
            // Then
            XCTAssertEqual(items, [1, 2, 3, 4])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatItRetrievesMoreItemsWhenKnownResultHasMoreItemsWithLocalDataStore() {
        // Given
        let store = LocalDataStore(items: [1, 2, 3, 4], limit: 2)
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveItems().then { items -> Promise<[Int]> in
            XCTAssertEqual(items, [1, 2])
            XCTAssertTrue(provider.hasMoreItems())
            return provider.retrieveMoreItems()
        }.then { items -> () in
            // Then
            XCTAssertEqual(items, [1, 2, 3, 4])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatItFallsBackToRetrieveItemsWhenNoResultIsKnownWhenCallingRetrievesMoreItems() {
        // Given
        let store = WritableStore(numbers: [1, 2], additionalItems: [3, 4])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveMoreItems().then { items -> () in
            // Then
            XCTAssertEqual(items, [1, 2])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatItRecoversFromErrorIfFailedDuringRetrieveItems() {
        // Given
        let store = ReadOnlyStore(forceErrorOnRetrieve: true, forceErrorOnRetrieveMoreItems: true)
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveItems().then { _ in
            XCTFail("This should not happen.")
        }.catch { error in
            // Then
            if case .error(let error) = provider.state {
                XCTAssertNotNil(error)
                expectation.fulfill()
            } else {
                XCTFail("This should not happen.")
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatItRecoversFromErrorIfFailedDuringRetrieveMoreItems() {
        // Given
        let store = ReadOnlyStore(forceErrorOnRetrieve: false, forceErrorOnRetrieveMoreItems: true)
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveItems().then { _ in
            return provider.retrieveMoreItems()
        }.then { _ -> () in
            XCTFail("This should not happen.")
        }.catch { error in
            // Then
            if case .error(let error) = provider.state {
                XCTAssertNotNil(error)
                expectation.fulfill()
            } else {
                XCTFail("This should not happen.")
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatItHandlesMultipleRetrieveRequestsBeautifully() {
        // Given
        let store = ReadOnlyStore(numbers: [1, 2, 3])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        _ = after(seconds: 0.1).then {
            XCTAssertEqual(provider.state, .loading)
        }

        let firstRetrieve = provider.retrieveItems()
        let secondRetrieve = provider.retrieveItems()

        when(fulfilled: firstRetrieve, secondRetrieve).then { firstResults, secondResults -> () in
            // Then
            XCTAssertEqual(firstResults, secondResults)
            XCTAssertEqual(store.retrieveCount, 1)
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItHandlesMultipleRetrieveMoreItemsRequestsBeautifully() {
        // Given
        let store = ReadOnlyStore(numbers: [1, 2, 3])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        _ = after(seconds: 0.1).then {
            XCTAssertEqual(provider.state, .loading)
        }

        _ = provider.retrieveItems().then { items -> Promise<([Int], [Int])>  in
            let firstRetrieve = provider.retrieveMoreItems()
            let secondRetrieve = provider.retrieveMoreItems()
            return when(fulfilled: firstRetrieve, secondRetrieve)
        }.then { firstResults, secondResults -> () in
            // Then
            XCTAssertEqual(firstResults, secondResults)
            XCTAssertEqual(store.retrieveCount, 2)
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 4.0)
    }

    func testThatItCancelsPreviusLowPriorityRequestWhenHigherRequestIsMade() {
        // Given
        let store = ReadOnlyStore(numbers: [1, 2, 3], additionalItems: [4, 5, 6])
        let provider = DataStoreCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        _ = provider.retrieveItems().then { _ -> () in
            XCTAssertTrue(provider.hasMoreItems())

            _ = provider.retrieveMoreItems().then { _ -> () in
                XCTFail("This should not happen.")
            }.catch { error in
                XCTAssertEqual((error as NSError).code, NSURLErrorCancelled)
            }

            after(seconds: 0.1).then {
                return provider.retrieveItems()
            }.then { items -> () in
                // Then
                XCTAssertEqual(items, [1, 2, 3])
                expectation.fulfill()
            }.catch { _ in
                XCTFail("This should not happen.")
            }
        }

        wait(for: [expectation], timeout: 4.0)
    }




}

struct NumberResult: PaginatedDataStoreResult {

    var items: [Int]

    var hasMoreItems: Bool

    init(items: [Int], hasMoreItems: Bool = false) {
        self.items = items
        self.hasMoreItems = hasMoreItems
    }

}

class ReadOnlyStore: ReadableDataStore {

    typealias Result = NumberResult

    let delay: Double

    private(set) var numbers: [Int]

    private(set) var additionalItems: [Int]?

    private(set) var retrieveCount: Int = 0

    let forceErrorOnRetrieve: Bool

    let forceErrorOnRetrieveMoreItems: Bool

    init(numbers: [Int] = [], additionalItems: [Int]? = nil, delay: Double = 1.0) {
        self.numbers = numbers
        self.delay = delay
        self.additionalItems = additionalItems
        self.forceErrorOnRetrieve = false
        self.forceErrorOnRetrieveMoreItems = false
    }

    init(forceErrorOnRetrieve: Bool, forceErrorOnRetrieveMoreItems: Bool, delay: Double = 1.0) {
        self.numbers = []
        self.delay = delay
        self.additionalItems = nil
        self.forceErrorOnRetrieve = forceErrorOnRetrieve
        self.forceErrorOnRetrieveMoreItems = forceErrorOnRetrieveMoreItems
    }

    func retrieveItems(withLastKnownResults results: ReadOnlyStore.Result?, cancelToken: PromiseCancellationToken?) -> Promise<ReadOnlyStore.Result> {
        return Promise { fullfill, reject in
            retrieveCount += 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
                if (self.forceErrorOnRetrieve && results == nil) || (self.forceErrorOnRetrieveMoreItems && results != nil) {
                    reject(NSError(domain: "com.readonly", code: NSURLErrorDataNotAllowed, userInfo: [:]))
                } else if cancelToken?.isCancelled == true {
                    reject(NSError.cancelledError())
                } else {
                    fullfill(NumberResult(items: results != nil ? self.additionalItems ?? [] : self.numbers, hasMoreItems: results == nil && self.additionalItems?.count ?? 0 > 0))
                }
            })
        }
    }

}

class WritableStore: WritableDataStore {

    typealias Result = NumberResult

    let delay: Double

    private(set) var numbers: [Int]

    private(set) var additionalItems: [Int]?

    init(numbers: [Int] = [], additionalItems: [Int]? = nil, delay: Double = 1.0) {
        self.numbers = numbers
        self.delay = delay
        self.additionalItems = additionalItems
    }

    func retrieveItems(withLastKnownResults results: ReadOnlyStore.Result?, cancelToken: PromiseCancellationToken?) -> Promise<ReadOnlyStore.Result> {
        return Promise { fullfill, reject in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
                fullfill(NumberResult(items: results != nil ? self.additionalItems ?? [] : self.numbers, hasMoreItems: results == nil && self.additionalItems?.count ?? 0 > 0))
            })
        }
    }

    func addItems(_ items: [Int]) -> Promise<[Int]> {
        numbers += items
        return Promise(value: items)
    }

    func removeItems(_ items: [Int]) -> Promise<[Int]> {
        items.forEach {
            if let index = self.numbers.index(of: $0) {
                self.numbers.remove(at: index)
            }
        }

        return Promise(value: items)
    }

    func replaceItem(_ item: Int, with otherItem: Int) -> Promise<Int> {
        if let index = numbers.index(of: item) {
            numbers.remove(at: index)
            numbers.insert(otherItem, at: index)
        }
        return Promise(value: otherItem)
    }

}
