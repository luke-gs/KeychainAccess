//
//  MediaDataSourceArray.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class LocalDataStoreTests: XCTestCase {

    func testThatItCreatesSuccessfully() {
        // Given
        let items = [
            Media(url: URL(fileURLWithPath: "test")),
            Media(url: URL(fileURLWithPath: "test"))
        ]

        // When
        let store = LocalDataStore(items: items)

        // Then
        XCTAssertEqual(store.items, items)

    }

    func testThatItIsExpressibleByArray() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"))

        // When
        let store: LocalDataStore = [item]

        // Then
        XCTAssertEqual(store.items, [item])

    }

    func testThatItAddsBeautifully() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"))
        let store: LocalDataStore<Media> = []

        let expectation = XCTestExpectation()

        // When
        store.addItem(item).then { item -> () in
            XCTAssertNotNil(item)
            expectation.fulfill()
        }.catch { error in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItDoesNotAddTheSameItem() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"))
        let store: LocalDataStore = [item]

        let expectation = XCTestExpectation()

        // When
        store.addItem(item).then { item -> () in
            XCTFail("This should not happen.")
        }.catch { error in
            XCTAssertEqual(error as! LocalDataStoreError, .duplicate)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItRemovesBeautifully() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"))
        let store: LocalDataStore = [item]

        let expectation = XCTestExpectation()

        // When
        store.removeItem(item).then { item -> () in
            XCTAssertNotNil(item)
            expectation.fulfill()
        }.catch { error in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItDoesNotRemoveNonExistentItem() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"))
        let store: LocalDataStore<Media> = []

        let expectation = XCTestExpectation()

        // When
        store.removeItem(item).then { item -> () in
            XCTFail("This should not happen.")
        }.catch { error in
            XCTAssertEqual(error as! LocalDataStoreError, .notFound)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItReplacesOldItemWithNewItem() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"))
        let store: LocalDataStore = [item]
        let newItem = Media(url: URL(fileURLWithPath: "test2"))

        let expectation = XCTestExpectation()

        // When
        store.replaceItem(item, with: newItem).then { item -> () in
            XCTAssertEqual(newItem, item)
            expectation.fulfill()
        }.catch { error in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItDoesNotReplaceNonExistentItem() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"))
        let newItem = Media(url: URL(fileURLWithPath: "test2"))
        let store: LocalDataStore<Media> = []

        let expectation = XCTestExpectation()

        // When
        store.replaceItem(item, with: newItem).then { newItem -> () in
            XCTFail("This should not happen.")
        }.catch { error in
            XCTAssertEqual(error as! LocalDataStoreError, .notFound)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItDoesNotReplaceWithADuplicateItem() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"))
        let newItem = Media(url: URL(fileURLWithPath: "test2"))
        let store: LocalDataStore = [item, newItem]

        let expectation = XCTestExpectation()

        // When
        store.replaceItem(item, with: newItem).then { newItem -> () in
            XCTFail("This should not happen.")
        }.catch { error in
            XCTAssertEqual(error as! LocalDataStoreError, .duplicate)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItRetrievesBeautifully() {
        // Given
        let items = [
            Media(url: URL(fileURLWithPath: "test")),
            Media(url: URL(fileURLWithPath: "test2"))
        ]

        let store = LocalDataStore(items: items)

        // When
        store.retrieveItems(withLastKnownResults: nil).then { results -> () in
            // Then
            let expectedResults = LocalDataResults(items: items)
            XCTAssertEqual(results.items, expectedResults.items)
        }.catch { error in
            XCTFail("This should not happen.")
        }
    }

}
