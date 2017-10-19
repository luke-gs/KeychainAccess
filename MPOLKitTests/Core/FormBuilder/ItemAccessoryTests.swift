//
//  ItemAccessoryTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ItemAccessoryTests: XCTestCase {

    func testThatItInstantiatesWithDisclosureStyle() {
        // Given
        let style = Style.disclosure

        // When
        let item = ItemAccessory(style: style)

        // Then
        XCTAssertTrue(item.style == style)
        XCTAssertTrue(item.size != .zero)
    }

    func testThatItInstantiatesWithCheckmarkStyle() {
        // Given
        let style = Style.checkmark

        // When
        let item = ItemAccessory(style: style)

        // Then
        XCTAssertTrue(item.style == style)
        XCTAssertTrue(item.size != .zero)
    }

    func testThatItInstantiatesWithDropDownStyle() {
        // Given
        let style = Style.dropDown

        // When
        let item = ItemAccessory(style: style)

        // Then
        XCTAssertTrue(item.style == style)
        XCTAssertTrue(item.size != .zero)
    }

    func testThatItCreatesTheViewWithDropdown() {
        // Given
        let item = ItemAccessory(style: .dropDown)

        // When
        let view = item.view()

        // Then
        XCTAssertTrue(view is FormAccessoryImageView)
        XCTAssertTrue((view as! FormAccessoryImageView).style == .dropDown)
    }

    func testThatItCreatesTheViewWithCheckmark() {
        // Given
        let item = ItemAccessory(style: .checkmark)

        // When
        let view = item.view()

        // Then
        XCTAssertTrue(view is FormAccessoryImageView)
        XCTAssertTrue((view as! FormAccessoryImageView).style == .checkmark)
    }

    func testThatItCreatesTheViewWithDisclosure() {
        // Given
        let item = ItemAccessory(style: .disclosure)

        // When
        let view = item.view()

        // Then
        XCTAssertTrue(view is FormAccessoryImageView)
        XCTAssertTrue((view as! FormAccessoryImageView).style == .disclosure)
    }

    func testThatItRejectsViewWithIncorrectType() {
        // Given
        let theme = ThemeManager.shared.theme(for: .current)
        let view = UIView()
        var item = ItemAccessory(style: .disclosure)
        item.tintColor = .red

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertNotEqual(view.tintColor, .red)
    }

    func testThatItIsCustomizable() {
        // Given
        var item = ItemAccessory(style: .dropDown)

        // When
        item.tintColor = .blue
        item.onThemeChanged = nil

        // Then
        XCTAssertEqual(item.tintColor, .blue)
        XCTAssertNil(item.onThemeChanged)
    }

    func testThatItAppliesTheSpecifiedTintColor() {
        // Given
        let view = FormAccessoryImageView(style: .dropDown)
        let theme = ThemeManager.shared.theme(for: .current)
        var item = ItemAccessory(style: .dropDown)
        item.tintColor = .blue

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(item.tintColor, .blue)
    }

    func testThatItAppliesThemeColorToDropDown() {
        // Given
        let view = FormAccessoryImageView(style: .dropDown)
        let theme = ThemeManager.shared.theme(for: .current)
        let item = ItemAccessory(style: .dropDown)

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.tintColor, theme.color(forKey: .primaryText))
    }

    func testThatItAppliesDefaultTintColorToCheckmark() {
        // Given
        let view = FormAccessoryImageView(style: .checkmark)
        let defaultTint = view.tintColor

        let theme = ThemeManager.shared.theme(for: .current)
        let item = ItemAccessory(style: .checkmark)

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.tintColor, defaultTint)
    }

    func testThatItAppliesDefaultTintColorToDisclosure() {
        // Given
        let view = FormAccessoryImageView(style: .disclosure)
        let theme = ThemeManager.shared.theme(for: .current)
        let item = ItemAccessory(style: .disclosure)

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.tintColor, theme.color(forKey: .disclosure))
    }

    func testThatItAppliesCustomTheme() {
        // Given
        let view = FormAccessoryImageView(style: .dropDown)
        let theme = ThemeManager.shared.theme(for: .current)
        var item = ItemAccessory(style: .dropDown)
        item.tintColor = .blue
        item.onThemeChanged = { theme, view in
            view.tintColor = .red
        }

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.tintColor, .red)
    }
    
}
