//
//  MediaDataSourceArray.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import XCTest
import PromiseKit
@testable import MPOLKit

class LocalDataStoreTests: XCTestCase {

    func testThatItCreatesSuccessfully() {
        // Given
        let items = [
            Media(url: URL(fileURLWithPath: "test"), type: .photo),
            Media(url: URL(fileURLWithPath: "test"), type: .photo)
        ]

        // When
        let store = LocalDataStore(items: items)

        // Then
        XCTAssertEqual(store.items, items)

    }

    func testThatItIsExpressibleByArray() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"), type: .photo)

        // When
        let store: LocalDataStore = [item]

        // Then
        XCTAssertEqual(store.items, [item])

    }

    func testThatItAddsBeautifully() {
        // Given
        let item = Media(url: URL(fileURLWithPath: "test"), type: .photo)
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
        let item = Media(url: URL(fileURLWithPath: "test"), type: .photo)
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
        let item = Media(url: URL(fileURLWithPath: "test"), type: .photo)
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
        let item = Media(url: URL(fileURLWithPath: "test"), type: .photo)
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
        let item = Media(url: URL(fileURLWithPath: "test"), type: .photo)
        let store: LocalDataStore = [item]
        let newItem = Media(url: URL(fileURLWithPath: "test2"), type: .photo)

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
        let item = Media(url: URL(fileURLWithPath: "test"), type: .photo)
        let newItem = Media(url: URL(fileURLWithPath: "test2"), type: .photo)
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
        let item = Media(url: URL(fileURLWithPath: "test"), type: .photo)
        let newItem = Media(url: URL(fileURLWithPath: "test2"), type: .photo)
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
            Media(url: URL(fileURLWithPath: "test"), type: .photo),
            Media(url: URL(fileURLWithPath: "test2"), type: .photo)
        ]

        let store = LocalDataStore(items: items)

        let expectation = XCTestExpectation()

        // When
        store.retrieveItems(withLastKnownResults: nil).then { results -> () in
            // Then
            let expectedResults = LocalDataResults(items: items)
            XCTAssertEqual(results.items, expectedResults.items)
            expectation.fulfill()
        }.catch { error in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatItRetrievesSuccessfullyWhenLimitIsSet() {
        // Given
        let initialItems = [
            Media(url: URL(fileURLWithPath: "test"), type: .photo),
            Media(url: URL(fileURLWithPath: "test2"), type: .photo),
        ]

        let additionalItems = [
            Media(url: URL(fileURLWithPath: "test3"), type: .photo),
            Media(url: URL(fileURLWithPath: "test4"), type: .photo),
        ]

        let store = LocalDataStore(items: initialItems + additionalItems, limit: 2)

        let expectation = XCTestExpectation()

        // When
        store.retrieveItems(withLastKnownResults: nil).then { results -> Promise<LocalDataResults<Media>> in
            // Then
            let expectedResults = LocalDataResults(items: initialItems, nextIndex: 2)
            XCTAssertEqual(results.items, expectedResults.items)
            return store.retrieveItems(withLastKnownResults: results)
        }.then { results -> () in
            let expectedResults = LocalDataResults(items: additionalItems, nextIndex: nil)
            XCTAssertEqual(results.items, expectedResults.items)
            expectation.fulfill()
        }.catch { error in
            XCTFail("This should not happen.")
        }

        wait(for: [expectation], timeout: 2.0)
    }

}
