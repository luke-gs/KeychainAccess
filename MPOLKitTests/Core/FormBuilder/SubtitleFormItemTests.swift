//
//  SubtitleFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class SubtitleFormItemTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // Given
        let title = "Hello"
        let subtitle = "Bye"
        let image = AssetManager.shared.image(forKey: .info)

        // When
        let item = SubtitleFormItem(title: title, subtitle: subtitle, image: image)

        // Then
        XCTAssertEqual(item.title?.sizing().string, title)
        XCTAssertEqual(item.subtitle?.sizing().string, subtitle)
        XCTAssertEqual(item.image, image)
        XCTAssertEqual(item.style, .default)
        XCTAssertTrue(item.cellType == CollectionViewFormSubtitleCell.self)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormSubtitleCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = SubtitleFormItem()

        // When
        item.title("Hello")
            .subtitle("Bye")
            .image(AssetManager.shared.image(forKey: .info))
            .style(.value)

        // Then
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.subtitle?.sizing().string, "Bye")
        XCTAssertEqual(item.image, AssetManager.shared.image(forKey: .info))
        XCTAssertEqual(item.style, .value)
    }

    func testThatItConfiguresView() {
        // Given
        let view = CollectionViewFormSubtitleCell()
        let item = SubtitleFormItem(title: "Hello")
            .subtitle("Bye")
            .image(AssetManager.shared.image(forKey: .info))

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.subtitleLabel.text, "Bye")
        XCTAssertEqual(view.imageView.image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = SubtitleFormItem(title: "Hello")

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = SubtitleFormItem(title: "Hello")

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormSubtitleCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = SubtitleFormItem(title: "Hello")

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.subtitleLabel.textColor, theme.color(forKey: .secondaryText))
    }

}
