//
//  SummaryListFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class SummaryListFormItemTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // When
        let item = SummaryListFormItem()

        // Then
        XCTAssertEqual(item.highlightStyle, .fade)
        XCTAssertEqual(item.badge, 0)
        XCTAssertTrue(item.cellType == EntityListCollectionViewCell.self)
        XCTAssertEqual(item.reuseIdentifier, EntityListCollectionViewCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = SummaryListFormItem()

        // When
        item.category("Today")
            .title("Hello")
            .subtitle("Bye")
            .badge(20)
            .badgeColor(.yellow)
            .borderColor(.orange)
            .image(AssetManager.shared.image(forKey: .info))

        // Then
        XCTAssertEqual(item.category, "Today")
        XCTAssertEqual(item.title, "Hello")
        XCTAssertEqual(item.subtitle, "Bye")
        XCTAssertEqual(item.badge, 20)
        XCTAssertEqual(item.badgeColor, .yellow)
        XCTAssertEqual(item.borderColor, .orange)
        XCTAssertEqual(item.image?.sizing().image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItConfiguresView() {
        // Given
        let view = EntityListCollectionViewCell()
        let item = SummaryListFormItem()
            .category("Today")
            .title("Hello")
            .subtitle("Bye")
            .badge(20)
            .badgeColor(.red)
            .borderColor(.yellow)
            .image(AssetManager.shared.image(forKey: .info))

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.sourceLabel.text, "Today")
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.subtitleLabel.text, "Bye")
        XCTAssertEqual(view.actionCount, 20)
        XCTAssertEqual(view.alertColor, .red)
        XCTAssertEqual(view.thumbnailView.borderColor, .yellow)
        XCTAssertEqual(view.thumbnailView.imageView.image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = SummaryListFormItem()

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = SummaryListFormItem()

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = EntityListCollectionViewCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = SummaryListFormItem()

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.subtitleLabel.textColor, theme.color(forKey: .secondaryText))
    }
    
}
