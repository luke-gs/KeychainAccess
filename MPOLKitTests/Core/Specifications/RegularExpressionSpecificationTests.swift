//
//  RegularExpressionSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class RegularExpressionSpecificationTests: XCTestCase {
    
    func testThatItIsSatisfied() {
        // Given
        let spec = RegularExpressionSpecification(pattern: "^[a-z]{3,10}$")

        // When
        let result = spec.isSatisfiedBy("text")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsNotSatisfied() {
        // Given
        let spec = RegularExpressionSpecification(pattern: "^[a-z]{3,10}$")

        // When
        let result = spec.isSatisfiedBy("a")

        // Then
        XCTAssertFalse(result)
    }

    func testThatItIsNotSatisfiedWhenInvalidCandidateIsUsed() {
        // Given
        let spec = RegularExpressionSpecification(pattern: "^[a-z]{3,10}$")

        // When
        let result = spec.isSatisfiedBy(100)

        // Then
        XCTAssertFalse(result)
    }
    
}
