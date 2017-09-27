//
//  UILayoutPriorityMathExtensionTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import MPOLKit

class UILayoutPriorityMathExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatItAdditionIsCorrect() {

        // Given
        let lowPriority = UILayoutPriority.defaultLow

        // When
        let slightlyHigherThanLowPriority = lowPriority + 1

        // Then
        XCTAssert(slightlyHigherThanLowPriority == UILayoutPriority(lowPriority.rawValue + 1))

    }

    func testThatItSubstractionIsCorrect() {

        // Given
        let requiredPriority = UILayoutPriority.required

        // When
        let almostRequired = requiredPriority - 1

        // Then
        XCTAssert(almostRequired == UILayoutPriority(requiredPriority.rawValue - 1))

    }

    func testThatAdditionAssignmentOperatorionIsCorrect() {

        // Given
        var lowPriority = UILayoutPriority.defaultLow

        // When
        lowPriority += 1

        // Then
        XCTAssert(lowPriority == UILayoutPriority(UILayoutPriority.defaultLow.rawValue + 1))

    }

    func testThatSubtractionAssignmentOperatorionIsCorrect() {

        // Given
        var requiredPriority = UILayoutPriority.required

        // When
        requiredPriority -= 1

        // Then
        XCTAssert(requiredPriority == UILayoutPriority(UILayoutPriority.required.rawValue - 1))

    }
}
