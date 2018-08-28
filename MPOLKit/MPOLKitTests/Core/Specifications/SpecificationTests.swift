//
//  SpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class SpecificationTests: XCTestCase {
    
    func testThatItCreatesAnAndSpecification() {
        // Given
        let spec1 = CountSpecification.min(1)
        let spec2 = CountSpecification.max(2)

        // When
        let combinedSpec = spec1.and(spec2)

        // Then
        XCTAssertTrue(combinedSpec is AndSpecification)
    }

    func testThatItCreatesAnOrSpecification() {
        // Given
        let spec1 = CountSpecification.min(1)
        let spec2 = CountSpecification.max(2)

        // When
        let combinedSpec = spec1.or(spec2)

        // Then
        XCTAssertTrue(combinedSpec is OrSpecification)
    }

    func testThatItCreatesANotSpecification() {
        // Given
        let spec1 = CountSpecification.min(1)

        // When
        let combinedSpec = spec1.not()

        // Then
        XCTAssertTrue(combinedSpec is NotSpecification)
    }

    func testThatItIsAlwaysFalseWhenFalseSpecificationIsUsed() {
        // Given
        let spec = FalseSpecification()
        
        // When
        let result = spec.isSatisfiedBy("Hello")
        
        // Then
        XCTAssertFalse(result)
    }

    func testThatItIsAlwaysTrueWhenFalseSpecificationIsUsed() {
        // Given
        let spec = TrueSpecification()

        // When
        let result = spec.isSatisfiedBy("Hello")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItCreatesAnAndSpecicationUsingOperator() {
        // Given
        let spec1 = TrueSpecification()
        let spec2 = FalseSpecification()

        // When
        let spec = spec1 & spec2

        // Then
        XCTAssertTrue(spec is AndSpecification)
    }

    func testThatItCreatesAnOrSpecicationUsingOperator() {
        // Given
        let spec1 = TrueSpecification()
        let spec2 = FalseSpecification()

        // When
        let spec = spec1 | spec2

        // Then
        XCTAssertTrue(spec is OrSpecification)
    }

    func testThatItCreatesANotSpecicationUsingOperator() {
        // Given
        let spec1 = TrueSpecification()

        // When
        let spec = !spec1

        // Then
        XCTAssertTrue(spec is NotSpecification)
    }

    func testThatItIsSatisfiedUsingOperator() {
        // Given
        let spec = TrueSpecification()

        // When
        let result = spec == "Hello"

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsNoteSatisfiedUsingOperator() {
        // Given
        let spec = TrueSpecification()

        // When
        let result = spec != "Hello"

        // Then
        XCTAssertFalse(result)
    }

}
