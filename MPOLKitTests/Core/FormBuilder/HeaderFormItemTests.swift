//
//  HeaderFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class HeaderFormItemTests: XCTestCase {

    func testThatItInstantiatesWithDefaultStyle() {
        // Given
        let text = "Hello"

        // When
        let item = HeaderFormItem(text: text)

        // Then
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.style, .plain)
        XCTAssertEqual(item.kind, UICollectionElementKindSectionHeader)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormHeaderView.defaultReuseIdentifier)
        XCTAssertTrue(item.viewType == CollectionViewFormHeaderView.self)
    }

    func testThatItInstantiatesWithPlainStyle() {
        // Given
        let text = "Hello"

        // When
        let item = HeaderFormItem(text: text, style: .plain)

        // Then
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.style, .plain)
    }

    func testThatItConfiguresViewWithCollisibleStyle() {
        // Given
        let item = HeaderFormItem(text: "Hello", style: .collapsible)
        let view = CollectionViewFormHeaderView()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.showsExpandArrow, true)
        XCTAssertEqual(view.isExpanded, true)
    }

    func testThatItConfiguresViewWithPlainStyle() {
        // Given
        let item = HeaderFormItem(text: "Hello", style: .plain)
        let view = CollectionViewFormHeaderView()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.showsExpandArrow, false)
        XCTAssertEqual(view.isExpanded, true)
    }

    func testThatItReturnsCorrectMinimumHeight() {
        // Given
        let item = HeaderFormItem(text: "Hello")

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), for: UITraitCollection())

        // Then
        XCTAssertEqual(height, CollectionViewFormHeaderView.minimumHeight)
    }

    func testThatItChains() {
        // Given
        let item = HeaderFormItem()

        // When
        item.text("Hello")
            .isExpanded(false)
            .separatorColor(.blue)
            .style(.plain)

        // Then
        XCTAssertFalse(item.isExpanded)
        XCTAssertEqual(item.separatorColor, .blue)
        XCTAssertEqual(item.style, .plain)
        XCTAssertEqual(item.text, "Hello")
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormHeaderView()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = HeaderFormItem(text: "Hello")

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.tintColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.separatorColor, theme.color(forKey: .separator))
    }

    func testThatItAppliesSpecifiedColors() {
        // Given
        let view = CollectionViewFormHeaderView()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = HeaderFormItem(text: "Hello")
        item.separatorColor = .blue

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.separatorColor, .blue)
    }


}
