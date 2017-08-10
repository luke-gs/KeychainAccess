//
//  SourceItem.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class SourceItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoadedStateEquality() {
        let sourceItem = SourceItem(title: "title", shortTitle: "short", state: .loaded(count: 0, color: .green))
        let testSourceItem = SourceItem(title: "title", shortTitle: "short", state: .loaded(count: 0, color: .green))

        XCTAssertEqual(sourceItem, testSourceItem)
    }

    func testLoadedStateInequalityColour() {
        let sourceItem = SourceItem(title: "title", shortTitle: "short", state: .loaded(count: 0, color: .green))
        let testSourceItem = SourceItem(title: "title", shortTitle: "short", state: .loaded(count: 0, color: .blue))

        XCTAssertNotEqual(sourceItem, testSourceItem)
    }

    func testLoadedStateInequalityCount() {
        let sourceItem = SourceItem(title: "title", shortTitle: "short", state: .loaded(count: 111, color: .green))
        let testSourceItem = SourceItem(title: "title", shortTitle: "short", state: .loaded(count: 0, color: .green))

        XCTAssertNotEqual(sourceItem, testSourceItem)
    }

    func testLoadedStateInequalityTitle() {
        let sourceItem = SourceItem(title: "title", shortTitle: "short", state: .loaded(count: 0, color: .green))
        let testSourceItem = SourceItem(title: "short", shortTitle: "short", state: .loaded(count: 0, color: .green))

        XCTAssertNotEqual(sourceItem, testSourceItem)
    }

    func testLoadedStateShortEquality() {
        let sourceItem = SourceItem(title: "title", shortTitle: "short", state: .loaded(count: 0, color: .green))
        let testSourceItem = SourceItem(title: "title", shortTitle: "title", state: .loaded(count: 0, color: .green))

        XCTAssertEqual(sourceItem, testSourceItem)
    }

    func testOtherStateEquality() {
        let sourceItem = SourceItem(title: "title", shortTitle: "short", state: .loading)
        let testSourceItem = SourceItem(title: "title", shortTitle: "short", state: .loading)

        XCTAssertEqual(sourceItem, testSourceItem)
    }
}

