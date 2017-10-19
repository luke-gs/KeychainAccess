//
//  ValidatorRuleTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit


class ValidatorRuleTests: XCTestCase {

    func testThatSoftRulesAreEqual() {
        // Given
        let rule1 = ValidatorRule.soft(specification: TrueSpecification(), message: "Hello")
        let rule2 = ValidatorRule.soft(specification: TrueSpecification(), message: "Hello")

        // When
        let same = rule1 == rule2

        // Then
        XCTAssertTrue(same)
    }

    func testThatStrictRulesAreEqual() {
        // Given
        let rule1 = ValidatorRule.strict(specification: TrueSpecification(), message: "Hello")
        let rule2 = ValidatorRule.strict(specification: TrueSpecification(), message: "Hello")

        // When
        let same = rule1 == rule2

        // Then
        XCTAssertTrue(same)
    }
    
    func testThatSubmitRulesAreEqual() {
        // Given
        let rule1 = ValidatorRule.submit(specification: TrueSpecification(), message: "Hello")
        let rule2 = ValidatorRule.submit(specification: TrueSpecification(), message: "Hello")

        // When
        let same = rule1 == rule2

        // Then
        XCTAssertTrue(same)
    }

    func testThatRulesAreNotEqual() {
        // Given
        let rule1 = ValidatorRule.soft(specification: TrueSpecification(), message: "Hello")
        let rule2 = ValidatorRule.submit(specification: TrueSpecification(), message: "Hello")

        // When
        let same = rule1 == rule2

        // Then
        XCTAssertFalse(same)
    }
    
}
