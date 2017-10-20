//
//  OptionFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class OptionFormItemTests: XCTestCase {

    func testThatItInstantiatesWithDefaults() {
        // Given
        let title = "Hello"
        let subtitle = "Bye"

        // When
        let item = OptionFormItem(title: title, subtitle: subtitle)

        // Then
        XCTAssertEqual(item.title?.sizing().string, title)
        XCTAssertEqual(item.subtitle?.sizing().string, subtitle)
        XCTAssertEqual(item.optionStyle, .checkbox)
        XCTAssertEqual(item.isChecked, false)
        XCTAssertTrue(item.cellType == CollectionViewFormOptionCell.self)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormOptionCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = OptionFormItem()

        // When
        item.optionStyle(.radio)
            .title("Hello")
            .subtitle("Bye")
            .imageSeparation(30.0)
            .labelSeparation(40.0)
            .isChecked(true)
            .onValueChanged(nil)

        // Then
        XCTAssertEqual(item.optionStyle, .radio)
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.subtitle?.sizing().string, "Bye")
        XCTAssertEqual(item.imageSeparation, 30.0)
        XCTAssertEqual(item.labelSeparation, 40.0)
        XCTAssertTrue(item.isChecked)
        XCTAssertNil(item.onValueChanged)
    }

    func testThatItConfiguresView() {
        // Given
        let view = CollectionViewFormOptionCell()
        let item = OptionFormItem(title: "Hello")
            .subtitle("Bye")
            .optionStyle(.checkbox)

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.optionStyle, .checkbox)
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.subtitleLabel.text, "Bye")
        XCTAssertEqual(view.isChecked, false)
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = OptionFormItem()

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = OptionFormItem()

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormOptionCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = OptionFormItem(title: "Hello")

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.subtitleLabel.textColor, theme.color(forKey: .primaryText))
    }

    func testThatItCallsOnValueChangedHandler() {
        // Given
        let expectation = XCTestExpectation()
        let view = CollectionViewFormOptionCell()
        let item = OptionFormItem(title: "Hello")
            .onValueChanged { (checked) -> (Void) in
                // Then
                expectation.fulfill()
            }

        // When
        item.configure(view)
        item.cell = view

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            view.valueChangedHandler?(true)
        }

        self.wait(for: [expectation], timeout: 0.1)
    }

    
}
