//
//  NotSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class NotSpecificationTests: XCTestCase {
    
    func testThatItSatisfied() {
        // Given
        let spec = NotSpecification(TrueSpecification())

        // When
        let thisIsFalse = spec.isSatisfiedBy("Hello")

        // Then
        XCTAssertFalse(thisIsFalse)
    }

}
