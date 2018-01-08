//
//  SummaryThumbnailFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class SummaryThumbnailFormItemTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // When
        let item = SummaryThumbnailFormItem()

        // Then
        XCTAssertEqual(item.style, .hero)
        XCTAssertEqual(item.separatorStyle, .none)
        XCTAssertEqual(item.highlightStyle, .animated(style: EnlargeStyle()))
        XCTAssertEqual(item.badge, 0)
        XCTAssertTrue(item.cellType == EntityCollectionViewCell.self)
        XCTAssertEqual(item.reuseIdentifier, EntityCollectionViewCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = SummaryThumbnailFormItem()

        // When
        item.style(.detail)
            .category("Today")
            .title("Hello")
            .subtitle("Bye")
            .detail("Detail")
            .badge(20)
            .badgeColor(.yellow)
            .borderColor(.orange)
            .image(AssetManager.shared.image(forKey: .info))

        // Then
        XCTAssertEqual(item.style, .detail)
        XCTAssertEqual(item.category, "Today")
        XCTAssertEqual(item.title, "Hello")
        XCTAssertEqual(item.subtitle, "Bye")
        XCTAssertEqual(item.detail, "Detail")
        XCTAssertEqual(item.badge, 20)
        XCTAssertEqual(item.badgeColor, .yellow)
        XCTAssertEqual(item.borderColor, .orange)
        XCTAssertEqual(item.image?.sizing().image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItConfiguresView() {
        // Given
        let view = EntityCollectionViewCell()
        let item = SummaryThumbnailFormItem()
            .category("Today")
            .title("Hello")
            .subtitle("Bye")
            .detail("Detail")
            .badge(20)
            .badgeColor(.yellow)
            .borderColor(.orange)
            .image(AssetManager.shared.image(forKey: .info))

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.sourceLabel.text, "Today")
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.subtitleLabel.text, "Bye")
        XCTAssertEqual(view.detailLabel.text, "Detail")
        XCTAssertEqual(view.badgeCount, 20)
        XCTAssertEqual(view.borderColor, .yellow)
        XCTAssertEqual(view.thumbnailView.borderColor, .orange)
        XCTAssertEqual(view.thumbnailView.imageView.image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = SummaryThumbnailFormItem()

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = SummaryThumbnailFormItem()

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = EntityCollectionViewCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = SummaryThumbnailFormItem()

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.subtitleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.detailLabel.textColor, theme.color(forKey: .secondaryText))
    }

}
