//
//  ValidatorTests.swift
//  MPOLKitTests
//
//  Created by Bryan Hathaway on 10/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

// MARK: - Validator

class ValidatorTests: XCTestCase {




}

// MARK: - ValidationRuleSet

class ValidationRuleSetTests: XCTestCase {

    func testThatItInstantiatesWithDefault() {
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [])
        XCTAssertEqual(ruleSet.invalidMessage, nil)
    }

    func testThatItInstantiatesWithRules() {
        // When
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [TrueSpecification()])

        // Then
        XCTAssertEqual(ruleSet.rules.count, 1)
    }

    func testThatItValidatesValidSpecifications() {
        // Given
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [TrueSpecification()])
        generalValidityAssert(ruleSet: ruleSet)
    }

    func testThatItValidatesInvalidSpecifications() {
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [FalseSpecification()])
        generalValidityAssert(ruleSet: ruleSet, expectsValid: false)
    }

    func testThatItValidatesMultipleValidRules() {
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [TrueSpecification(), TrueSpecification()])
        generalValidityAssert(ruleSet: ruleSet)
    }

    func testThatItValidatesMultipleInvalidRules() {
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [FalseSpecification(), FalseSpecification()])
        generalValidityAssert(ruleSet: ruleSet, expectsValid: false)
    }

    func testThatItValidatesMultipleRulesWithDifferentValidities() {
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [TrueSpecification(), FalseSpecification()])
        generalValidityAssert(ruleSet: ruleSet, expectsValid: false)
    }

    func testThatItProvidesMessageOnInvalid() {
        // Given
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [FalseSpecification()], invalidMessage: "Invalid message")

        // When
        let result = generalValidityAssert(ruleSet: ruleSet, expectsValid: false)

        // Then
        if case .invalid(let description) = result {
            XCTAssert(description == "Invalid message")
        }
    }

    func testThatItValidatesWhenNoSpecifications() {
        let ruleSet = ValidationRuleSet(candidate: 0, rules: [])
        generalValidityAssert(ruleSet: ruleSet)
    }

    func testValidCountSpecification() {
        let ruleSet = ValidationRuleSet(candidate: "1234567", rules: [CountSpecification.min(5)])
        generalValidityAssert(ruleSet: ruleSet)
    }

    func testInvalidCountSpecification() {
        let ruleSet = ValidationRuleSet(candidate: "123", rules: [CountSpecification.min(5)])
        generalValidityAssert(ruleSet: ruleSet, expectsValid: false)
    }


    //MARK: Helper

    @discardableResult
    func generalValidityAssert(ruleSet: ValidationRuleSet, expectsValid: Bool = true) -> ValidationState {
        let result = ruleSet.validityState
        XCTAssert(enumIsCaseValid(state: result) == expectsValid)
        return result
    }

    func enumIsCaseValid(state: ValidationState) -> Bool {
        if case .valid = state {
            return true
        } else {
            return false
        }
    }
}
