//
//  ValidateResultTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ValidateResultTests: XCTestCase {

    func testThatValidResultsAreEqual() {
        // Given
        let result1 = ValidateResult.valid
        let result2 = ValidateResult.valid

        // When
        let same = result1 == result2

        // Then
        XCTAssertTrue(same)
    }

    func testThatSoftInvalidResultsAreEqual() {
        // Given
        let result1 = ValidateResult.softInvalid(message: "Hello")
        let result2 = ValidateResult.softInvalid(message: "Hello")

        // When
        let same = result1 == result2

        // Then
        XCTAssertTrue(same)
    }

    func testThatStrictInvalidResultsAreEqual() {
        // Given
        let result1 = ValidateResult.strictInvalid(message: "Hello")
        let result2 = ValidateResult.strictInvalid(message: "Hello")

        // When
        let same = result1 == result2

        // Then
        XCTAssertTrue(same)
    }

    func testThatSoftInvalidResultsAreNotEqual() {
        // Given
        let result1 = ValidateResult.softInvalid(message: "Hello")
        let result2 = ValidateResult.softInvalid(message: "ByeBye")

        // When
        let same = result1 == result2

        // Then
        XCTAssertFalse(same)
    }


    func testThatStrictInvalidResultsAreNotEqual() {
        // Given
        let result1 = ValidateResult.strictInvalid(message: "Hello")
        let result2 = ValidateResult.strictInvalid(message: "ByeBye")

        // When
        let same = result1 == result2

        // Then
        XCTAssertFalse(same)
    }

    func testThatValidIsNotEqualToSoftInvalid() {
        // Given
        let result1 = ValidateResult.valid
        let result2 = ValidateResult.softInvalid(message: "Hello")

        // When
        let same = result1 == result2

        // Then
        XCTAssertFalse(same)
    }

    func testThatValidIsNotEqualToStrictInvalid() {
        // Given
        let result1 = ValidateResult.valid
        let result2 = ValidateResult.strictInvalid(message: "Hello")

        // When
        let same = result1 == result2

        // Then
        XCTAssertFalse(same)
    }

    func testThatSoftInvalidIsNotEqualToStrictInvalid() {
        // Given
        let result1 = ValidateResult.softInvalid(message: "Hello")
        let result2 = ValidateResult.strictInvalid(message: "Hello")

        // When
        let same = result1 == result2

        // Then
        XCTAssertFalse(same)
    }

}
