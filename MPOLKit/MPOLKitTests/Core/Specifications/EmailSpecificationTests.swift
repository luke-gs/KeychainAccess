//
//  EmailSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class EmailSpecificationTests: XCTestCase {
    
    func testThatItIsSatisfiedWhenValidEmailIsUsed() {
        // Given
        let spec = EmailSpecification()

        // When
        let result = spec.isSatisfiedBy("herlihalim@gmail.com")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsNotSatisfiedWhenInvalidEmailIsUsed() {
        // Given
        let spec = EmailSpecification()

        // When
        let result = spec.isSatisfiedBy("herlihalim") || spec.isSatisfiedBy("@gmail.com") || spec.isSatisfiedBy("herlihalim@com") || spec.isSatisfiedBy("herlihalim")

        // Then
        XCTAssertFalse(result)
    }
    
}
