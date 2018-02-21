//
//  DataCoordinateStateTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 21/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit


class DataCoordinateStateTests: XCTestCase {
    
    func testThatItIsEqualWhenComparingCommonCases() {
        XCTAssertEqual(DataCoordinateState.unknown, DataCoordinateState.unknown)
        XCTAssertEqual(DataCoordinateState.loading, DataCoordinateState.loading)
        XCTAssertEqual(DataCoordinateState.completed, DataCoordinateState.completed)
    }

    func testThatItIsNotEqualWhenComparingCommonCases() {
        // Given
        let error = NSError(domain: "error", code: -100, userInfo: [:])

        XCTAssertNotEqual(DataCoordinateState.unknown, DataCoordinateState.loading)
        XCTAssertNotEqual(DataCoordinateState.unknown, DataCoordinateState.completed)
        XCTAssertNotEqual(DataCoordinateState.unknown, DataCoordinateState.error(error))
        XCTAssertNotEqual(DataCoordinateState.loading, DataCoordinateState.completed)
        XCTAssertNotEqual(DataCoordinateState.loading, DataCoordinateState.error(error))
        XCTAssertNotEqual(DataCoordinateState.completed, DataCoordinateState.error(error))
    }

    func testThatItIsEqualWhenComparingErrorCases() {
        // Given
        let a = DataCoordinateState.error(NSError(domain: "error", code: -100, userInfo: [:]))
        let b = DataCoordinateState.error(NSError(domain: "error", code: -100, userInfo: [:]))

        // Then
        XCTAssertEqual(a, b)
    }

    func testThatItIsNotEqualWhenComparingErrorCases() {
        // Given
        let a = DataCoordinateState.error(NSError(domain: "error", code: -100, userInfo: [:]))
        let b = DataCoordinateState.error(NSError(domain: "reject", code: -101, userInfo: [:]))

        // Then
        XCTAssertNotEqual(a, b)
    }

}
