//
//  PredicateSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class PredicateSpecificationTests: XCTestCase {
    
    func testThatItIsSatisfied() {
        // Given
        let spec = PredicateSpecification<String> { (text) -> Bool in
            return text.characters.count > 2
        }

        // When
        let result = spec.isSatisfiedBy("Text")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsNotSatisfied() {
        // Given
        let spec = PredicateSpecification<String> { (text) -> Bool in
            return text.characters.count > 4
        }

        // When
        let result = spec.isSatisfiedBy("A")

        // Then
        XCTAssertFalse(result)
    }

    func testThatItIsNotSatisfiedWhenInvalidCandidateIsUsed() {
        // Given
        let spec = PredicateSpecification<String> { (text) -> Bool in
            return text.characters.count > 4
        }

        // When
        let result = spec.isSatisfiedBy(100)

        // Then
        XCTAssertFalse(result)
    }
    
}
