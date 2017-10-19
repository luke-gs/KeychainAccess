//
//  StringSizing+LabelTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import UIKit
@testable import MPOLKit

class StringSizing_LabelTests: XCTestCase {

    func testThatItMakesRequired() {
        // Given
        var sizable = "Hello".sizing()

        // When
        sizable.makeRequired()

        // Then
        XCTAssertEqual(sizable.string, "Hello*")
    }

    func testThatItStylesLabelWithSizableUsingDefaults() {
        // Given
        let sizable = StringSizing(string: "Hello", font: nil, numberOfLines: nil)

        // When
        let label = UILabel()
        label.apply(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(label.text, "Hello")
        XCTAssertEqual(label.numberOfLines, 1)
        XCTAssertEqual(label.font, .systemFont(ofSize: 15))
    }

    func testThatItStylesLabelWithStringUsingDefaults() {
        // Given
        let sizable = "Hello"

        // When
        let label = UILabel()
        label.apply(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(label.text, "Hello")
        XCTAssertEqual(label.numberOfLines, 1)
        XCTAssertEqual(label.font, .systemFont(ofSize: 15))
    }

    func testThatItStylesLabelUsingSpecificSizing() {
        // Given
        let sizable = StringSizing(string: "Hello", font: .systemFont(ofSize: 12), numberOfLines: 3)

        // When
        let label = UILabel()
        label.apply(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(label.text, "Hello")
        XCTAssertEqual(label.numberOfLines, 3)
        XCTAssertEqual(label.font, .systemFont(ofSize: 12))
    }

    func testThatItStylesLabelUsingStringWithRequired() {
        // Given
        let label = UILabel()

        // When
        label.makeRequired(with: "Hello")

        // Then
        XCTAssertEqual(label.text, "Hello*")
    }

    func testThatItStylesLabelUsingSizableWithRequired() {
        // Given
        let label = UILabel()
        let sizing = StringSizing(string: "Hello", font: nil, numberOfLines: nil)

        // When
        label.makeRequired(with: sizing)

        // Then
        XCTAssertEqual(label.text, "Hello*")
    }

    func testThatItStylesLabelWithNilStringWithRequired() {
        // Given
        let label = UILabel()

        // When
        label.makeRequired(with: nil)

        // Then
        XCTAssertEqual(label.text, "*")
    }

    func testThatItStylesFormTextFieldWithTextUsingDefaults() {
        // Given
        let sizable = "Hello"

        // When
        let textField = FormTextField()
        textField.applyText(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textField.text, "Hello")
        XCTAssertEqual(textField.font, .systemFont(ofSize: 15))
    }

    func testThatItStylesFormTextFieldWithSizableUsingDefaults() {
        // Given
        let sizable = StringSizing(string: "Hello", font: nil, numberOfLines: nil)

        // When
        let textField = FormTextField()
        textField.applyText(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textField.text, "Hello")
        XCTAssertEqual(textField.font, .systemFont(ofSize: 15))
    }

    func testThatItStylesFormTextFieldWithSizableUsingSpecificSizing() {
        // Given
        let sizable = StringSizing(string: "Hello", font: .systemFont(ofSize: 12), numberOfLines: nil)

        // When
        let textField = FormTextField()
        textField.applyText(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textField.text, "Hello")
        XCTAssertEqual(textField.font, .systemFont(ofSize: 12))
    }

    func testThatItStylesFormTextFieldPlaceholderWithTextUsingDefaults() {
        // Given
        let sizable = "Hello"

        // When
        let textField = FormTextField()
        textField.applyPlaceholder(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textField.placeholder, "Hello")
        XCTAssertEqual(textField.placeholderFont, .systemFont(ofSize: 15))
    }

    func testThatItStylesFormTextFieldPlaceholderWithSizableUsingDefaults() {
        // Given
        let sizable = StringSizing(string: "Hello", font: nil, numberOfLines: nil)

        // When
        let textField = FormTextField()
        textField.applyPlaceholder(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textField.placeholder, "Hello")
        XCTAssertEqual(textField.placeholderFont, .systemFont(ofSize: 15))
    }

    func testThatItStylesFormTextFieldPlaceholderWithSizableUsingSpecificSizing() {
        // Given
        let sizable = StringSizing(string: "Hello", font: .systemFont(ofSize: 12), numberOfLines: nil)

        // When
        let textField = FormTextField()
        textField.applyPlaceholder(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textField.placeholder, "Hello")
        XCTAssertEqual(textField.placeholderFont, .systemFont(ofSize: 12))
    }

    func testThatItStylesFormTextViewWithTextUsingDefaults() {
        // Given
        let sizable = "Hello"

        // When
        let textView = FormTextView()
        textView.apply(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textView.text, "Hello")
        XCTAssertEqual(textView.font, .systemFont(ofSize: 15))
    }

    func testThatItStylesFormTextViewWithSizableUsingDefaults() {
        // Given
        let sizable = StringSizing(string: "Hello", font: nil, numberOfLines: nil)

        // When
        let textView = FormTextView()
        textView.apply(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textView.text, "Hello")
        XCTAssertEqual(textView.font, .systemFont(ofSize: 15))
    }

    func testThatItStylesFormTextViewWithSizableUsingSpecificSizing() {
        // Given
        let sizable = StringSizing(string: "Hello", font: .systemFont(ofSize: 12), numberOfLines: nil)

        // When
        let textView = FormTextView()
        textView.apply(sizable: sizable, defaultFont: .systemFont(ofSize: 15))

        // Then
        XCTAssertEqual(textView.text, "Hello")
        XCTAssertEqual(textView.font, .systemFont(ofSize: 12))
    }

}
