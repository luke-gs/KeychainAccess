//
//  DetailFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class DetailFormItemTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // Given
        let title = "Hello"
        let subtitle = "Bye"
        let detail = "Details"
        let image = AssetManager.shared.image(forKey: .info)

        // When
        let item = DetailFormItem(title: title, subtitle: subtitle, detail: detail, image: image)

        // Then
        XCTAssertEqual(item.title?.sizing().string, title)
        XCTAssertEqual(item.subtitle?.sizing().string, subtitle)
        XCTAssertEqual(item.detail?.sizing().string, detail)
        XCTAssertEqual(item.image, image)
        XCTAssertTrue(item.cellType == CollectionViewFormDetailCell.self)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormDetailCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = DetailFormItem()

        // When
        item.title("Hello")
            .subtitle("Bye")
            .detail("Detail")
            .image(AssetManager.shared.image(forKey: .info))

        // Then
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.subtitle?.sizing().string, "Bye")
        XCTAssertEqual(item.detail?.sizing().string, "Detail")
        XCTAssertEqual(item.image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItConfiguresView() {
        // Given
        let view = CollectionViewFormDetailCell()
        let item = DetailFormItem(title: "Hello")
            .subtitle("Bye")
            .detail("Detail")
            .image(AssetManager.shared.image(forKey: .info))

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.subtitleLabel.text, "Bye")
        XCTAssertEqual(view.detailLabel.text, "Detail")
        XCTAssertEqual(view.imageView.image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = DetailFormItem(title: "Hello")

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = DetailFormItem(title: "Hello")

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormDetailCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = DetailFormItem(title: "Hello")

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.subtitleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.detailLabel.textColor, theme.color(forKey: .primaryText))
    }
    
}
