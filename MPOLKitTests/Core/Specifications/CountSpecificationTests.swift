//
//  CountSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class CountSpecificationTests: XCTestCase {
    
    func testThatItIsSatisfiedBetweenMinAndMax() {
        // Given
        let spec = CountSpecification.between(4, 10)

        // When
        let result = spec.isSatisfiedBy("1234") && spec.isSatisfiedBy("134567") && spec.isSatisfiedBy("1234567890")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenExactCountIsUsed() {
        // Given
        let spec = CountSpecification.exactly(4)

        // When
        let result = spec.isSatisfiedBy("1234") && !spec.isSatisfiedBy("123456") && !spec.isSatisfiedBy("123")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsNotSatisfiedWhenMinIsNotMet() {
        // Given
        let spec = CountSpecification.min(4)

        // When
        let result = spec.isSatisfiedBy("123")

        // Then
        XCTAssertFalse(result)
    }

    func testThatItIsNotSatisfiedWhenMaxIsNotMet() {
        // Given
        let spec = CountSpecification.max(10)

        // When
        let result = spec.isSatisfiedBy("12345678901")

        // Then
        XCTAssertFalse(result)
    }

    func testThatItIsNotSatisfiedWhenCandidateIsNil() {
        // Given
        let spec = CountSpecification.between(4, 10)

        // When
        let result = spec.isSatisfiedBy(nil)

        // Then
        XCTAssertFalse(result)
    }

    func testThatItIsSatisfiedWhenArrayIsUsed() {
        // Given
        let spec = CountSpecification.between(4, 10)

        // When
        let result = spec.isSatisfiedBy(["1", "2", "3", "4"])

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenIndexSetIsUsed() {
        // Given
        let spec = CountSpecification.between(4, 10)
        var indexSet = IndexSet()
        indexSet.insert(1)
        indexSet.insert(2)
        indexSet.insert(3)
        indexSet.insert(4)
        indexSet.insert(5)

        // When
        let result = spec.isSatisfiedBy(indexSet)

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenSetIsUsed() {
        // Given
        let spec = CountSpecification.between(4, 10)
        var set = Set<Int>()
        set.insert(1)
        set.insert(2)
        set.insert(3)
        set.insert(4)
        set.insert(5)

        // When
        let result = spec.isSatisfiedBy(set)

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsNotSatisfiedWhenCandidateIsNotSupported() {
        // Given
        let spec = CountSpecification.between(4, 10)
        let invalidCandidate = 323

        // When
        let result = spec.isSatisfiedBy(invalidCandidate)

        // Then
        XCTAssertFalse(result)
    }

}
