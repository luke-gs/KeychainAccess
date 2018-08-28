//
//  OrSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class OrSpecificationTests: XCTestCase {
    
    func testThatItIsSatisfiedWhenBothSpecsAreSatisfied() {
        // Given
        let text = "12345"
        let spec = OrSpecification(TrueSpecification(), TrueSpecification())

        // When
        let satisfied = spec.isSatisfiedBy(text)

        // Then
        XCTAssertTrue(satisfied)
    }

    func testThatItIsSatisfiedWhenFirstSpecIsSatisfied() {
        // Given
        let text = "123"
        let spec = OrSpecification(TrueSpecification(), FalseSpecification())

        // When
        let satisfied = spec.isSatisfiedBy(text)

        // Then
        XCTAssertTrue(satisfied)
    }

    func testThatItIsSatisfiedWhenSecondSpecIsSatisfied() {
        // Given
        let text = "123"
        let spec = OrSpecification(FalseSpecification(), TrueSpecification())

        // When
        let satisfied = spec.isSatisfiedBy(text)

        // Then
        XCTAssertTrue(satisfied)
    }

    func testThatItIsNotSatisfiedWhenBothSpecsAreNotSatisfied() {
        // Given
        let text = "123"
        let spec = OrSpecification(FalseSpecification(), FalseSpecification())

        // When
        let satisfied = spec.isSatisfiedBy(text)

        // Then
        XCTAssertFalse(satisfied)
    }
    
}
