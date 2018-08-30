//
//  NotNilSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class NotNilSpecificationTests: XCTestCase {
    
    func testThatItIsSatisfied() {
        // Given
        let candidate = "Hello"
        let specification = NotNilSpecification()

        // When
        let satisfied = specification.isSatisfiedBy(candidate)

        // Then
        XCTAssertTrue(satisfied)
    }

    func testThatItIsNotSatisfied() {
        // Given
        let candidate: Int? = nil
        let specification = NotNilSpecification()

        // When
        let satisfied = specification.isSatisfiedBy(candidate)

        // Then
        XCTAssertFalse(satisfied)
    }
    
}
