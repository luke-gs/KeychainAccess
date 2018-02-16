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
        let store: NumberStore = NumberStore()

        // When
        let provider = DataCoordinator(dataStore: store)

        // Then
        XCTAssertEqual(provider.state, .unknown)
        XCTAssertEqual(provider.items.count, 0)
    }

    func testThatItRetrievesItems() {
        // Given
        let store = NumberStore(numbers: [1, 2, 3])
        let provider = DataCoordinator(dataStore: store)

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
        let store = NumberStore(numbers: [1, 2])
        let provider = DataCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.addItem(3).then { _ in
            return provider.retrieveItems()
        }.then { _ -> () in
            XCTAssertEqual(provider.items, [1, 2, 3])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItRemovesItem() {
        // Given
        let store = NumberStore(numbers: [1, 2])
        let provider = DataCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.removeItem(2).then { _ in
            return provider.retrieveItems()
        }.then { _ -> () in
            XCTAssertEqual(provider.items, [1])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItReplacesItem() {
        // Given
        let store = NumberStore(numbers: [1, 2])
        let provider = DataCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.replaceItem(2, with: 3).then { _ in
            return provider.retrieveItems()
        }.then { _ -> () in
            XCTAssertEqual(provider.items, [1, 3])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItHasMoreItems() {
        // Given
        let store = NumberStore(numbers: [1, 2], additionalItems: [3, 4])
        let provider = DataCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveItems().then { _ -> () in
            XCTAssertTrue(provider.hasMoreItems())
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testThatItRetrievesMoreItems() {
        // Given
        let store = NumberStore(numbers: [1, 2], additionalItems: [3, 4])
        let provider = DataCoordinator(dataStore: store)

        let expectation = XCTestExpectation()

        // When
        provider.retrieveItems().then { _ in
            return provider.retrieveMoreItems()
        }.then { items -> () in
            XCTAssertEqual(items, [1, 2, 3, 4])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 3.0)
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

class NumberStore: DataStore {

    typealias Result = NumberResult

    let delay: Double

    private(set) var numbers: [Int]

    private(set) var additionalItems: [Int]?

    init(numbers: [Int] = [], additionalItems: [Int]? = nil, delay: Double = 1.0) {
        self.numbers = numbers
        self.delay = delay
        self.additionalItems = additionalItems
    }

    func retrieveItems(withLastKnownResults results: NumberStore.Result?, cancelToken: PromiseCancellationToken?) -> Promise<NumberStore.Result> {
        return Promise { fullfill, reject in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
                fullfill(NumberResult(items: results != nil ? self.additionalItems ?? [] : self.numbers, hasMoreItems: results == nil && self.additionalItems?.count ?? 0 > 0))
            })
        }
    }

    func addItem(_ item: Int) -> Promise<Int> {
        numbers.append(item)
        return Promise(value: item)
    }

    func removeItem(_ item: Int) -> Promise<Int> {
        if let index = numbers.index(of: item) {
            numbers.remove(at: index)
        }
        return Promise(value: item)
    }

    func replaceItem(_ item: Int, with otherItem: Int) -> Promise<Int> {
        if let index = numbers.index(of: item) {
            numbers.remove(at: index)
            numbers.insert(otherItem, at: index)
        }
        return Promise(value: otherItem)
    }

}

