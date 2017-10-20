//
//  CharacterSetSpecificationTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class CharacterSetSpecificationTests: XCTestCase {

    func testThatItIsSatisfiedWhenCustomCharacterSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.charactersInString("ABCDE")

        // When
        let result = spec.isSatisfiedBy("ABC") && !spec.isSatisfiedBy("LOLOL")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsNotSatisfiedWhenInvalidCandidateIsUsed() {
        // Given
        let spec = CharacterSetSpecification.charactersInString("ABCDE")

        // When
        let result = spec.isSatisfiedBy(3939)

        // Then
        XCTAssertFalse(result)
    }

    func testThatItIsSatisfiedWhenAlphanumericsSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.alphanumerics

        // When
        let result = spec.isSatisfiedBy("abcd123") && !spec.isSatisfiedBy("$)(add99")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenCapitalizedLettersSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.capitalizedLetters

        // When
        let result = spec.isSatisfiedBy("ᾈ")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenControlSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.controlCharacters

        // When
        let result = spec.isSatisfiedBy("\n") && !spec.isSatisfiedBy("tssst")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenControlDecimalSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.decimalDigits

        // When
        let result = spec.isSatisfiedBy("12303") && !spec.isSatisfiedBy("ahdhd33")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenUppercaseSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.uppercaseLetters

        // When
        let result = spec.isSatisfiedBy("LOKDOD") && !spec.isSatisfiedBy("ahdhd33")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenLowercaseSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.lowercaseLetters

        // When
        let result = spec.isSatisfiedBy("akdkdkd") && !spec.isSatisfiedBy("JIDID")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenLettersSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.letters

        // When
        let result = spec.isSatisfiedBy("Jdidhdakdkdkd") && !spec.isSatisfiedBy("838")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenWhitespacesSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.whitespaces

        // When
        let result = spec.isSatisfiedBy(" ") && !spec.isSatisfiedBy("838")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenWhitespacesAndNewlinesSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.whitespacesAndNewlines

        // When
        let result = spec.isSatisfiedBy("   \n") && !spec.isSatisfiedBy("838")

        // Then
        XCTAssertTrue(result)
    }

    func testThatItIsSatisfiedWhenNewlinesSetIsUsed() {
        // Given
        let spec = CharacterSetSpecification.newlines

        // When
        let result = spec.isSatisfiedBy("\n") && !spec.isSatisfiedBy("838")

        // Then
        XCTAssertTrue(result)
    }

}
