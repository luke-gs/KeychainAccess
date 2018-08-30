//
//  StringSizingTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class StringSizingTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // Given
        let string = "Hello"

        // When
        let sizing = StringSizing(string: string)

        // Then
        XCTAssertEqual(sizing.string, string)
        XCTAssertNil(sizing.font)
        XCTAssertNil(sizing.numberOfLines)
    }

    func testThatItIsSizable() {
        // Given
        let sizing = StringSizing(string: "Hello")

        // When
        let theSizing = sizing.sizing()

        // Then
        XCTAssertEqual(sizing, theSizing)
    }

    func testThatItIsEqual() {
        // Given
        let sizingA = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)
        let sizingB = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)

        // When
        let same = sizingA == sizingB

        // Then
        XCTAssertTrue(same)
    }

    func testThatItIsNotEqualIfStringsAreDifferent() {
        // Given
        let sizingA = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)
        let sizingB = StringSizing(string: "Hi", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)

        // When
        let same = sizingA == sizingB

        // Then
        XCTAssertFalse(same)
    }

    func testThatItIsNotEqualIfFontsAreDifferent() {
        // Given
        let sizingA = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)
        let sizingB = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 20.0), numberOfLines: 2)

        // When
        let same = sizingA == sizingB

        // Then
        XCTAssertFalse(same)
    }

    func testThatItIsNotEqualIfNumberOfLinesAreDifferent() {
        // Given
        let sizingA = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)
        let sizingB = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 1)

        // When
        let same = sizingA == sizingB

        // Then
        XCTAssertFalse(same)
    }

    func testThatItReturnsMinimumWidth() {
        // Given
        let sizing = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)

        // When
        let width = sizing.minimumWidth(compatibleWith: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsZeroMinimumWidthWhenThereIsNoString() {
        // Given
        let sizing = StringSizing(string: "", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)

        // When
        let width = sizing.minimumWidth(compatibleWith: UITraitCollection())

        // Then
        XCTAssertEqual(width, 0.0)
    }

    func testThatItReturnsDefaultMinimumWidthWhenItIsNegativeNumberOfLines() {
        // Given
        let sizing = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: -10)

        // When
        let width = sizing.minimumWidth(compatibleWith: UITraitCollection())

        // Then
        XCTAssertEqual(width, 10.0)
    }

    func testThatItReturnsMinimumHeight() {
        // Given
        let sizing = StringSizing(string: "Hello", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)

        // When
        let height = sizing.minimumHeight(inWidth: 300.0, allowingZeroHeight: true, compatibleWith: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItReturnsZeroMinimumHeightWhenThereIsNoString() {
        // Given
        let sizing = StringSizing(string: "", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)

        // When
        let height = sizing.minimumHeight(inWidth: 300.0, allowingZeroHeight: true, compatibleWith: UITraitCollection())

        // Then
        XCTAssertEqual(height, 0.0)
    }

    func testThatItReturnsMinimumHeightWhenThereIsNoString() {
        // Given
        let sizing = StringSizing(string: "", font: UIFont.systemFont(ofSize: 23.0), numberOfLines: 2)

        // When
        let height = sizing.minimumHeight(inWidth: 300.0, allowingZeroHeight: false, compatibleWith: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItHasSizingForString() {
        // Given
        let text = "Hello"

        // When
        let sizing = text.sizing()

        // Then
        XCTAssertEqual(sizing.string, text)
        XCTAssertNil(sizing.font)
        XCTAssertNil(sizing.numberOfLines)
    }

    
}
