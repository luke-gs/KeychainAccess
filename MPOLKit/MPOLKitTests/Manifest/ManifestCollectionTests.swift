//
//  ManifestCollectionTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ManifestCollectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEquality() {
        let collection = ManifestCollection(rawValue: "test")
        let testCollection = ManifestCollection(rawValue: "test")

        XCTAssertEqual(collection, testCollection)
    }

    func testInequality() {
        let collection = ManifestCollection(rawValue: "test")
        let testCollection = ManifestCollection(rawValue: "test2")

        XCTAssertNotEqual(collection, testCollection)
    }

    func testHashEquality() {
        let collection = ManifestCollection(rawValue: "test").hashValue
        let testCollection = ManifestCollection(rawValue: "test").hashValue

        XCTAssertEqual(collection, testCollection)
    }

    func testHashInequality() {
        let collection = ManifestCollection(rawValue: "test").hashValue
        let testCollection = ManifestCollection(rawValue: "test2").hashValue

        XCTAssertNotEqual(collection, testCollection)
    }
}

