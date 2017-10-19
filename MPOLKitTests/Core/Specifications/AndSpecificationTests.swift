//
//  AndSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class AndSpecificationTests: XCTestCase {
    
    func testThatItIsSatisfied() {
        // Given
        let text = "1234567"
        let spec = AndSpecification(TrueSpecification(), TrueSpecification())

        // When
        let satisfied = spec.isSatisfiedBy(text)

        // Then
        XCTAssertTrue(satisfied)
    }

    func testThatItIsNotSatisfiedIfFirstSpecIsNotSatisfied() {
        // Given
        let text = "12345"
        let spec = AndSpecification(FalseSpecification(), TrueSpecification())

        // When
        let satisfied = spec.isSatisfiedBy(text)

        // Then
        XCTAssertFalse(satisfied)
    }

    func testThatItIsNotSatisfiedIfSecondSpecIsNotSatisfied() {
        // Given
        let text = "12345"
        let spec = AndSpecification(TrueSpecification(), FalseSpecification())

        // When
        let satisfied = spec.isSatisfiedBy(text)

        // Then
        XCTAssertFalse(satisfied)
    }

    func testThatItIsNotSatisfiedIfBothSpecsAreNotSatisfied() {
        // Given
        let text = "12345"
        let spec = AndSpecification(FalseSpecification(), FalseSpecification())

        // When
        let satisfied = spec.isSatisfiedBy(text)

        // Then
        XCTAssertFalse(satisfied)
    }

}
