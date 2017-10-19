//
//  ValueFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ValueFormItemTests: XCTestCase {

    func testThatItInstantiatesWithDefaults() {
        // Given
        let title = "Hello"
        let value = "Bye"
        let image = AssetManager.shared.image(forKey: .info)

        // When
        let item = ValueFormItem(title: title, value: value, image: image)

        // Then
        XCTAssertEqual(item.title?.sizing().string, title)
        XCTAssertEqual(item.value?.sizing().string, value)
        XCTAssertEqual(item.image, image)
        XCTAssertTrue(item.cellType == CollectionViewFormValueFieldCell.self)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormValueFieldCell.defaultReuseIdentifier)
        XCTAssertEqual(item.imageSeparation, CellImageLabelSeparation)
        XCTAssertEqual(item.labelSeparation, CellTitleSubtitleSeparation)
    }

    func testThatItChains() {
        // Given
        let item = ValueFormItem()

        // When
        item.title("Hello")
            .value("Bye")
            .image(AssetManager.shared.image(forKey: .info))
            .imageSeparation(10.0)
            .labelSeparation(15.0)

        // Then
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.value?.sizing().string, "Bye")
        XCTAssertEqual(item.image, AssetManager.shared.image(forKey: .info))
        XCTAssertEqual(item.imageSeparation, 10.0)
        XCTAssertEqual(item.labelSeparation, 15.0)
    }

    func testThatItConfiguresView() {
        // Given
        let view = CollectionViewFormValueFieldCell()
        let item = ValueFormItem(title: "Hello")
            .value("Bye")
            .image(AssetManager.shared.image(forKey: .info))

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.valueLabel.text, "Bye")
        XCTAssertEqual(view.imageView.image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = ValueFormItem(title: "Hello")

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = ValueFormItem(title: "Hello")

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormValueFieldCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = ValueFormItem(title: "Hello")

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.valueLabel.textColor, theme.color(forKey: .secondaryText))
    }

}
