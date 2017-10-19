//
//  ValidatorTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ValidatorTests: XCTestCase {

    func testThatItInstantiatesWithDefault() {
        // When
        let validator = Validator()

        // Then
        XCTAssertEqual(validator.rules.count, 0)
    }
    
    func testThatItInstantiatesWithRules() {
        // Given
        let rule = ValidatorRule.soft(specification: TrueSpecification(), message: "Hello")

        // When
        let validator = Validator(rules: [rule])

        // Then
        XCTAssertEqual(validator.rules.count, 1)
    }

    func testThatItAddsRule() {
        // Given
        let rule = ValidatorRule.soft(specification: TrueSpecification(), message: "Hello")
        let validator = Validator()

        // When
        validator.addRule(rule)

        // Then
        XCTAssert(validator.rules[0] == rule)
        XCTAssert(validator.rules.count == 1)
    }

    func testThatItFailsValidationsAgainstSoftRule() {
        // Given
        let soft = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Soft rule message")
        let strict = ValidatorRule.strict(specification: CountSpecification.min(10), message: "Strict rule message")
        let submit = ValidatorRule.submit(specification: CountSpecification.min(20), message: "Submit rule message")
        let validator = Validator(rules: [soft, strict, submit])

        // When
        let result = validator.validate("Four", checkHardRule: false, checkSoftRule: true, checkSubmitRule: false)

        // Then
        XCTAssertFalse(result.isValid())
        XCTAssertEqual(result.message(), "Soft rule message")
    }

    func testThatItFailsValidationAgainstStrictRule() {
        // Given
        let soft = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Soft rule message")
        let strict = ValidatorRule.strict(specification: CountSpecification.min(10), message: "Strict rule message")
        let submit = ValidatorRule.submit(specification: CountSpecification.min(20), message: "Submit rule message")
        let validator = Validator(rules: [soft, strict, submit])

        // When
        let result = validator.validate("Four", checkHardRule: true, checkSoftRule: false, checkSubmitRule: false)

        // Then
        XCTAssertFalse(result.isValid())
        XCTAssertEqual(result.message(), "Strict rule message")
    }

    func testThatItFailsValidationAgainstSubmitRule() {
        // Given
        let soft = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Soft rule message")
        let strict = ValidatorRule.strict(specification: CountSpecification.min(10), message: "Strict rule message")
        let submit = ValidatorRule.submit(specification: CountSpecification.min(20), message: "Submit rule message")
        let validator = Validator(rules: [soft, strict, submit])

        // When
        let result = validator.validate("Four", checkHardRule: false, checkSoftRule: false, checkSubmitRule: true)

        // Then
        XCTAssertFalse(result.isValid())
        XCTAssertEqual(result.message(), "Submit rule message")
    }

    func testThatItFailsValidatationAgainstAnyRules() {
        // Given
        let soft = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Soft rule message")
        let strict = ValidatorRule.strict(specification: CountSpecification.min(10), message: "Strict rule message")
        let submit = ValidatorRule.submit(specification: CountSpecification.min(20), message: "Submit rule message")
        let validator = Validator(rules: [soft, strict, submit])

        // When
        let result = validator.validate("Four", checkHardRule: true, checkSoftRule: true, checkSubmitRule: true)

        // Then
        XCTAssertFalse(result.isValid())
        XCTAssertEqual(result.message(), "Strict rule message")
    }

    func testThatItPassesValidationsAgainstAnyRules() {
        // Given
        let soft = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Soft rule message")
        let strict = ValidatorRule.strict(specification: CountSpecification.min(10), message: "Strict rule message")
        let submit = ValidatorRule.submit(specification: CountSpecification.min(20), message: "Submit rule message")
        let validator = Validator(rules: [soft, strict, submit])

        // When
        let result = validator.validate("This is a message that is longer than 2 characters", checkHardRule: false, checkSoftRule: true, checkSubmitRule: false)

        // Then
        XCTAssertTrue(result.isValid())
        XCTAssertNil(result.message())
    }

    func testThatItValidatesWhenThereAreMultipleRulesScenarioOne() {
        // Given
        let soft1 = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Min 5 characters")
        let soft2 = ValidatorRule.soft(specification: CharacterSetSpecification.alphanumerics, message: "Alphanumeric only")
        let validator = Validator(rules: [soft1, soft2])

        // When
        let result = validator.validate("Four", checkHardRule: false, checkSoftRule: true, checkSubmitRule: false)

        // Then
        XCTAssertFalse(result.isValid())
        XCTAssertEqual(result.message(), "Min 5 characters")
    }

    func testThatItValidatesWhenThereAreMultipleRulesScenarioTwo() {
        // Given
        let soft1 = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Min 5 characters")
        let soft2 = ValidatorRule.soft(specification: CharacterSetSpecification.alphanumerics, message: "Alphanumeric only")
        let validator = Validator(rules: [soft1, soft2])

        // When
        let result = validator.validate("$FourAndAbove", checkHardRule: false, checkSoftRule: true, checkSubmitRule: false)

        // Then
        XCTAssertFalse(result.isValid())
        XCTAssertEqual(result.message(), "Alphanumeric only")
    }

    func testThatItValidatesAndUpdateErrorWhenValidatingAgainstSoftRule() {
        // Given
        let item = TextFieldFormItem()
        let soft1 = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Min 5 characters")
        let validator = Validator(rules: [soft1])

        // When
        validator.validateAndUpdateErrorIfNeeded("Four", shouldInstallTimer: false, checkSubmitRule: false, forItem: item)

        // Then
        let errorText = item.focusedText

        XCTAssertEqual(errorText, "Min 5 characters")
    }

    func testThatItValidatesAndUpdateErrorWhenValidatingAgainstStrictRule() {
        // Given
        let item = TextFieldFormItem()
        let soft1 = ValidatorRule.strict(specification: CountSpecification.min(5), message: "Min 5 characters")
        let validator = Validator(rules: [soft1])

        // When
        validator.validateAndUpdateErrorIfNeeded("Four", shouldInstallTimer: false, checkSubmitRule: false, forItem: item)

        // Then
        let errorText = item.focusedText

        XCTAssertEqual(errorText, "Min 5 characters")
    }

    func testThatItValidatesAndUpdateErrorWhenValidatingAgainstSubmitRule() {
        // Given
        let item = TextFieldFormItem()
        let soft1 = ValidatorRule.submit(specification: CountSpecification.min(5), message: "Min 5 characters")
        let validator = Validator(rules: [soft1])

        // When
        validator.validateAndUpdateErrorIfNeeded("Four", shouldInstallTimer: false, checkSubmitRule: true, forItem: item)

        // Then
        let errorText = item.focusedText

        XCTAssertEqual(errorText, "Min 5 characters")
    }

    func testThatItPassesValidationsAndUpdatesError() {
        // Given
        let item = TextFieldFormItem().focusedText("Existing error message")
        let soft1 = ValidatorRule.submit(specification: CountSpecification.min(5), message: "Min 5 characters")
        let validator = Validator(rules: [soft1])

        // When
        validator.validateAndUpdateErrorIfNeeded("FiveOrMore", shouldInstallTimer: false, checkSubmitRule: true, forItem: item)

        // Then
        let errorText = item.focusedText

        XCTAssertNil(errorText)
    }

    func testThatItBypassesValidationsAndUpdateErrorWhenCandidateIsNil() {
        // Given
        let item = TextFieldFormItem().focusedText("Existing error message")
        let soft1 = ValidatorRule.soft(specification: CountSpecification.min(5), message: "Min 5 characters")
        let validator = Validator(rules: [soft1])

        // When
        validator.validateAndUpdateErrorIfNeeded(nil, shouldInstallTimer: false, checkSubmitRule: false, forItem: item)

        // Then
        let errorText = item.focusedText

        XCTAssertEqual(errorText, nil)
    }

    func testThatItValidatesAndUpdatesErrorWithTimerInstalled() {
        // Given
        let item = TextFieldFormItem()
        let soft1 = ValidatorRule.strict(specification: CountSpecification.min(5), message: "Min 5 characters")
        let validator = Validator(rules: [soft1])

        // When
        validator.validateAndUpdateErrorIfNeeded("Four", shouldInstallTimer: true, checkSubmitRule: false, forItem: item)

        // Then
        let errorText = item.focusedText
        XCTAssertEqual(errorText, "Min 5 characters")

        let expect = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.1) {
            XCTAssertEqual(item.focusedText, nil)
            expect.fulfill()
        }

        self.wait(for: [expect], timeout: 2.2)
    }

    func testThatItIgnoresNonFormValidatableWhenItValidatesAndUpdatesErrorWithTimerInstalled() {
        // Given
        let item = SubtitleFormItem()
        let soft1 = ValidatorRule.strict(specification: CountSpecification.min(5), message: "Min 5 characters")
        let validator = Validator(rules: [soft1])

        // When
        validator.validateAndUpdateErrorIfNeeded("Four", shouldInstallTimer: true, checkSubmitRule: false, forItem: item)

        // Then
        let errorText = item.focusedText
        XCTAssertEqual(errorText, "Min 5 characters")

        let expect = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.1) {
            XCTAssertEqual(item.focusedText, "Min 5 characters")
            expect.fulfill()
        }

        self.wait(for: [expect], timeout: 2.2)
    }

}
