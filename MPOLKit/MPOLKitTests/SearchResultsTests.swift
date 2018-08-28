//
//  SearchResultsTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Unbox
@testable import MPOLKit

class SearchResultsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRangeEquality() {
        let testEntity = MPOLKitEntity()
        let result = SearchResult(range: 0..<5, results: [testEntity])
        let testResult = SearchResult(range: 0..<5, results: [testEntity])

        XCTAssertEqual(result.range, testResult.range)
    }

    func testRangeInequality() {
        let testEntity = MPOLKitEntity()
        let result = SearchResult(range: 0..<8, results: [testEntity])
        let testResult = SearchResult(range: 0..<5, results: [testEntity])

        XCTAssertNotEqual(result.range, testResult.range)
    }

    func testResultsInequality() {
        let testEntity = MPOLKitEntity()
        let result = SearchResult(range: 0..<5, results: [testEntity, testEntity])
        let testResult = SearchResult(range: 0..<5, results: [testEntity])

        XCTAssertNotEqual(result.results, testResult.results)
    }

    func testUnboxerEquality() {
        let data: [String: Any] = ["firstItem": 0,
                                   "lastItem": 10,
                                   "searchResultsTotal": 10,
                                   "searchResults": Array(repeating: "1", count: 10)]

        let boxer = Unboxer(dictionary: data)

        let result = try! SearchResult<String>(unboxer: boxer)
        let testResult = try! SearchResult<String>(unboxer: boxer)

        XCTAssertEqual(result.range, testResult.range)
    }

    func testUnboxerInequality() {
        let data1: [String: Any] = ["firstItem": 0,
                                    "lastItem": 10,
                                    "searchResultsTotal": 10,
                                    "searchResults": Array(repeating: "1", count: 100)]
        let data2: [String: Any] = ["firstItem": 0,
                                    "lastItem": 9,
                                    "searchResultsTotal": 9,
                                    "searchResults": Array(repeating: "1", count: 9)]

        let boxer1 = Unboxer(dictionary: data1)
        let boxer2 = Unboxer(dictionary: data2)

        let result = try! SearchResult<String>(unboxer: boxer1)
        let testResult = try! SearchResult<String>(unboxer: boxer2)

        XCTAssertNotEqual(result.results, testResult.results)
        XCTAssertNotEqual(result.range, testResult.range)
    }

}

