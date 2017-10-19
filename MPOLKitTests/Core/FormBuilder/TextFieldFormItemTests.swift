//
//  TextFieldFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class TextFieldFormItemTests: XCTestCase {

    func testThatItInstantiatesWithDefaults() {
        // Given
        let title = "Hello"
        let text = "Bye"
        let placeholder = "Hi"

        // When
        let item = TextFieldFormItem(title: title, text: text, placeholder: placeholder)

        // Then
        XCTAssertEqual(item.title?.sizing().string, title)
        XCTAssertEqual(item.text?.sizing().string, text)
        XCTAssertEqual(item.placeholder?.sizing().string, placeholder)
        XCTAssertEqual(item.contentMode, .top)
        XCTAssertEqual(item.selectionStyle, .underline)
        XCTAssertTrue(item.cellType == CollectionViewFormTextFieldCell.self)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormTextFieldCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = TextFieldFormItem()

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
        let view = CollectionViewFormTextFieldCell()
        let item = TextFieldFormItem()
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
        XCTAssertEqual(view.textField.text, "Bye")
        XCTAssertEqual(view.textField.placeholder, "Hi")
        XCTAssertEqual(view.labelSeparation, 30.0)
        XCTAssertEqual(view.textField.autocorrectionType, .yes)
        XCTAssertEqual(view.textField.autocapitalizationType, .sentences)
        XCTAssertEqual(view.textField.spellCheckingType, .yes)
        XCTAssertEqual(view.textField.keyboardType, .namePhonePad)
        XCTAssertEqual(view.textField.keyboardAppearance, .light)
        XCTAssertEqual(view.textField.returnKeyType, .go)
        XCTAssertEqual(view.textField.enablesReturnKeyAutomatically, true)
        XCTAssertEqual(view.textField.textContentType, .countryName)
    }

    func testThatItConfiguresViewWithNoPlaceholderAndIsRequired() {
        // Given
        let view = CollectionViewFormTextFieldCell()
        let item = TextFieldFormItem()
            .title("Hi")
            .required()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.textField.placeholder, FormRequired.default.requiredPlaceholder)
    }

    func testThatItConfiguresViewWithNoPlaceholderAndIsNotRequired() {
        // Given
        let view = CollectionViewFormTextFieldCell()
        let item = TextFieldFormItem()
            .title("Hi")
            .notRequired()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.textField.placeholder, FormRequired.default.notRequiredPlaceholder)
    }

    func testThatItRemovesExistingTargetsWhenConfiguringTextField() {
        // Given
        let view = CollectionViewFormTextFieldCell()
        view.textField.addTarget(self, action: #selector(testThatItRemovesExistingTargetsWhenConfiguringTextField), for: .editingChanged)
        let item = TextFieldFormItem()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.textField.actions(forTarget: item, forControlEvent: .editingChanged)?.count, 1)
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = TextFieldFormItem().title("Hello").required()

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = TextFieldFormItem().title("Hello").required()

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormTextFieldCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = TextFieldFormItem(title: "Hello").required()

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.textField.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.textField.placeholderTextColor, theme.color(forKey: .placeholderText))
    }
    
}
