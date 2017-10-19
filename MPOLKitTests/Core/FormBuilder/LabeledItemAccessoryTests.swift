//
//  LabeledItemAccessoryTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class LabeledItemAccessoryTests: XCTestCase {

    func testThatItInstantiates() {
        // Given
        let title = "Boy"
        let subtitle = "Girl"
        let accessory = ItemAccessory.dropDown

        // When
        let item = LabeledItemAccessory(title: title, subtitle: subtitle, accessory: accessory)

        // Then
        XCTAssertEqual(item.title, title)
        XCTAssertEqual(item.subtitle, subtitle)
        XCTAssertTrue(item.accessory is ItemAccessory)
        XCTAssertTrue(item.size != .zero)
    }

    func testThatItChains() {
        // Given
        let item = LabeledItemAccessory(title: "Boy", subtitle: "Girl")

        // When
        item.titleColor(.red)
            .subtitleColor(.blue)
            .accessory(ItemAccessory.checkmark)
            .onThemeChanged(nil)

        // Then
        XCTAssertEqual(item.titleColor, .red)
        XCTAssertEqual(item.subtitleColor, .blue)
        XCTAssertNil(item.onThemeChanged)
    }

    func testThatItCreatesView() {
        // Given
        let item = LabeledItemAccessory(title: "Boy", subtitle: "Girl", accessory: ItemAccessory.dropDown)

        // When
        let view = item.view() as! LabeledAccessoryView

        // Then
        XCTAssertEqual(view.titleLabel.text, "Boy")
        XCTAssertEqual(view.subtitleLabel.text, "Girl")
        XCTAssertTrue(view.accessoryView is FormAccessoryImageView)

    }

    func testThatItAppliesTheSpecifiedColors() {
        // Given
        let theme = ThemeManager.shared.theme(for: .current)
        let item = LabeledItemAccessory(title: "Boy", subtitle: "Girl", accessory: ItemAccessory.dropDown)
        item.titleColor = .blue
        item.subtitleColor = .red
        let view = item.view() as! LabeledAccessoryView

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, .blue)
        XCTAssertEqual(view.subtitleLabel.textColor, .red)
    }

    func testThatItAppliesTheme() {
        // Given
        let theme = ThemeManager.shared.theme(for: .current)
        let item = LabeledItemAccessory(title: "Boy", subtitle: "Girl", accessory: ItemAccessory.dropDown)
        let view = item.view() as! LabeledAccessoryView

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.subtitleLabel.textColor, theme.color(forKey: .secondaryText))
    }

    func testThatItAppliesCustomTheme() {
        // Given
        let theme = ThemeManager.shared.theme(for: .current)
        let item = LabeledItemAccessory(title: "Boy", subtitle: "Girl", accessory: ItemAccessory.dropDown)
        item.titleColor = .blue
        item.subtitleColor = .red
        item.onThemeChanged = { theme, view in
            view.titleLabel.textColor = .orange
            view.subtitleLabel.textColor = .orange
        }

        let view = item.view() as! LabeledAccessoryView

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, .orange)
        XCTAssertEqual(view.subtitleLabel.textColor, .orange)
    }

    func testThatItRejectsInvalidView() {
        // Given
        let theme = ThemeManager.shared.theme(for: .current)
        let item = LabeledItemAccessory(title: "Boy", subtitle: "Girl", accessory: ItemAccessory.dropDown)

        item.onThemeChanged = { theme, view in
            // Then
            XCTAssertTrue(false, "This should not be called.")
        }

        let view = UILabel()

        // When
        item.apply(theme: theme, toView: view)
    }

}
