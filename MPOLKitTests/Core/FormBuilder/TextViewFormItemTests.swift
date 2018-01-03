//
//  TextViewFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class TextViewFormItemTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // Given
        let title = "Hello"
        let text = "Bye"
        let placeholder = "Hi"

        // When
        let item = TextViewFormItem(title: title, text: text, placeholder: placeholder)

        // Then
        XCTAssertEqual(item.title?.sizing().string, title)
        XCTAssertEqual(item.text?.sizing().string, text)
        XCTAssertEqual(item.placeholder?.sizing().string, placeholder)
        XCTAssertEqual(item.contentMode, .top)
        XCTAssertEqual(item.selectionStyle, UnderlineStyle.selection())
        XCTAssertTrue(item.cellType == CollectionViewFormTextViewCell.self)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormTextViewCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = TextViewFormItem()

        // When
        item.title("Hello")
            .text("Bye")
            .placeholder("Hi")
            .notRequired()
            .required()
            .labelSeparation(30.0)
            .softValidate(CountSpecification.min(1), message: "Invalid")
            .strictValidate(CountSpecification.min(1), message: "Invalid")
            .submitValidate(CountSpecification.min(1), message: "Invalid")
            .onValueChanged(nil)
            .autocapitalizationType(.sentences)
            .autocorrectionType(.yes)
            .spellCheckingType(.yes)
            .keyboardType(.namePhonePad)
            .keyboardAppearance(.light)
            .returnKeyType(.go)
            .enablesReturnKeyAutomatically(true)
            .secureTextEntry(true)
            .textContentType(.countryName)

        // Then
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.text?.sizing().string, "Bye")
        XCTAssertEqual(item.placeholder?.sizing().string, "Hi")
        XCTAssertEqual(item.labelSeparation, 30.0)
        XCTAssertTrue(item.isRequired)
        XCTAssertNil(item.onValueChanged)
        XCTAssertEqual(item.autocorrectionType, .yes)
        XCTAssertEqual(item.autocapitalizationType, .sentences)
        XCTAssertEqual(item.spellCheckingType, .yes)
        XCTAssertEqual(item.keyboardType, .namePhonePad)
        XCTAssertEqual(item.keyboardAppearance, .light)
        XCTAssertEqual(item.returnKeyType, .go)
        XCTAssertEqual(item.enablesReturnKeyAutomatically, true)
        XCTAssertEqual(item.secureTextEntry, true)
        XCTAssertEqual(item.textContentType, .countryName)
    }

    func testThatItConfiguresViewWithPlaceholder() {
        // Given
        let view = CollectionViewFormTextViewCell()
        let item = TextViewFormItem()
            .title("Hello")
            .text("Bye")
            .placeholder("Hi")
            .labelSeparation(30.0)
            .autocapitalizationType(.sentences)
            .autocorrectionType(.yes)
            .spellCheckingType(.yes)
            .keyboardType(.namePhonePad)
            .keyboardAppearance(.light)
            .returnKeyType(.go)
            .enablesReturnKeyAutomatically(true)
            .textContentType(.countryName)

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.textView.text, "Bye")
        XCTAssertEqual(view.textView.placeholderLabel.text, "Hi")
        XCTAssertEqual(view.labelSeparation, 30.0)
        XCTAssertEqual(view.textView.autocorrectionType, .yes)
        XCTAssertEqual(view.textView.autocapitalizationType, .sentences)
        XCTAssertEqual(view.textView.spellCheckingType, .yes)
        XCTAssertEqual(view.textView.keyboardType, .namePhonePad)
        XCTAssertEqual(view.textView.keyboardAppearance, .light)
        XCTAssertEqual(view.textView.returnKeyType, .go)
        XCTAssertEqual(view.textView.enablesReturnKeyAutomatically, true)
        XCTAssertEqual(view.textView.textContentType, .countryName)
    }

    func testThatItConfiguresViewWithNoPlaceholderAndIsRequired() {
        // Given
        let view = CollectionViewFormTextViewCell()
        let item = TextViewFormItem()
            .title("Hi")
            .required()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.textView.placeholderLabel.text, FormRequired.default.requiredPlaceholder)
    }

    func testThatItConfiguresViewWithNoPlaceholderAndIsNotRequired() {
        // Given
        let view = CollectionViewFormTextViewCell()
        let item = TextViewFormItem()
            .title("Hi")
            .notRequired()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.textView.placeholderLabel.text, FormRequired.default.notRequiredPlaceholder)
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = TextViewFormItem().title("Hello").required()

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 40.0), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = TextViewFormItem().title("Hello").required()

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormTextViewCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = TextViewFormItem(title: "Hello").required()

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.textView.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.textView.placeholderLabel.textColor, theme.color(forKey: .placeholderText))
    }

    func testThatItsCandidateIsTheSameAsItsText() {
        // Given
        let item = TextViewFormItem(title: "Hello").text("Hello")

        // When
        let candidate = item.candidate

        // Then
        XCTAssertEqual(item.text?.sizing().string, candidate as? String)
    }
    
}
