//
//  FooterFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class FooterFormItemTests: XCTestCase {

    func testThatItInstantiatesWithDefauts() {
        // Given
        let text = "Hello"

        // When
        let item = FooterFormItem(text: text)

        // Then
        XCTAssertEqual(item.text, text)
        XCTAssert(item.viewType == CollectionViewFormFooterView.self)
        XCTAssertEqual(item.kind, UICollectionElementKindSectionFooter)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormFooterView.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = FooterFormItem()

        // When
        item.text("Hello")

        // Then
        XCTAssertEqual(item.text, "Hello")
    }

    func testThatItConfiguresView() {
        // Given
        let item = FooterFormItem(text: "Hello")
        let view = CollectionViewFormFooterView()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.text, "Hello")
    }

    func testThatItReturnCorrectsHeight() {
        // Given
        let item = FooterFormItem(text: "Hello")

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), for: UITraitCollection())

        // Then
        XCTAssertEqual(height, CollectionViewFormFooterView.minimumHeight)
    }

    func testThatItAppliesTheme() {
        // Given
        let theme = ThemeManager.shared.theme(for: .current)
        let view = CollectionViewFormFooterView()
        let item = FooterFormItem(text: "Hello")

        // When
        item.apply(theme: theme, toView: view)

        // Then
        XCTAssertEqual(view.tintColor, theme.color(forKey: .secondaryText))
    }

}
