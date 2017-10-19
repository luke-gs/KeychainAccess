//
//  SummaryDetailFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class SummaryDetailFormItemTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // When
        let item = SummaryDetailFormItem()

        // Then
        XCTAssertEqual(item.contentMode, .top)
        XCTAssertTrue(item.cellType == EntityDetailCollectionViewCell.self)
        XCTAssertEqual(item.reuseIdentifier, EntityDetailCollectionViewCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = SummaryDetailFormItem()

        // When
        item.category("Today")
            .title("Hello")
            .subtitle("Bye")
            .detail("Detail")
            .detailPlaceholder(true)
            .borderColor(.orange)
            .image(AssetManager.shared.image(forKey: .info))
            .buttonTitle("Action")
            .onButtonTapped(nil)
            .onImageTapped(nil)


        // Then
        XCTAssertEqual(item.category, "Today")
        XCTAssertEqual(item.title, "Hello")
        XCTAssertEqual(item.subtitle, "Bye")
        XCTAssertEqual(item.detail, "Detail")
        XCTAssertEqual(item.isDetailPlaceholder, true)
        XCTAssertEqual(item.borderColor, .orange)
        XCTAssertEqual(item.image?.sizing().image, AssetManager.shared.image(forKey: .info))
        XCTAssertEqual(item.buttonTitle, "Action")
        XCTAssertNil(item.onButtonTapped)
        XCTAssertNil(item.onImageTapped)
    }

    func testThatItConfiguresView() {
        // Given
        let view = EntityDetailCollectionViewCell()
        let item = SummaryDetailFormItem()
            .category("Today")
            .title("Hello")
            .subtitle("Bye")
            .detail("Detail")
            .detailPlaceholder(true)
            .borderColor(.orange)
            .image(AssetManager.shared.image(forKey: .info))
            .buttonTitle("Action")
            .onButtonTapped({ })
            .onImageTapped({ })

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.sourceLabel.text, "Today")
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.subtitleLabel.text, "Bye")
        XCTAssertEqual(view.descriptionLabel.text, "Detail")
        XCTAssertEqual(view.isDescriptionPlaceholder, true)
        XCTAssertEqual(view.additionalDetailsButton.title(for: .normal), "Action")
        XCTAssertEqual(view.thumbnailView.borderColor, .orange)
        XCTAssertEqual(view.thumbnailView.imageView.image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = SummaryDetailFormItem()

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeightWhenItIsDetailPlaceholder() {
        // Given
        let item = SummaryDetailFormItem().detailPlaceholder(true)

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = SummaryDetailFormItem()

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 40), collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = EntityDetailCollectionViewCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = SummaryDetailFormItem()

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.subtitleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.descriptionLabel.textColor, theme.color(forKey: .secondaryText))
    }

    func testThatItAppliesThemeWhenThereIsDetailPlaceholder() {
        // Given
        let view = EntityDetailCollectionViewCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = SummaryDetailFormItem().detailPlaceholder(true)

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .primaryText))
        XCTAssertEqual(view.subtitleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.descriptionLabel.textColor, theme.color(forKey: .placeholderText))
    }

    func testThatItNotifiesOnButtonTapped() {
        // Given
        let expectation = XCTestExpectation()
        let view = EntityDetailCollectionViewCell()
        let item = SummaryDetailFormItem().onButtonTapped({
            // Then
            expectation.fulfill()
        })

        // When
        item.configure(view)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            view.additionalDetailsButtonActionHandler?(view)
        }

        self.wait(for: [expectation], timeout: 0.1)
    }

    func testThatItNotifiesOnImageTapped() {
        // Given
        let expectation = XCTestExpectation()
        let view = EntityDetailCollectionViewCell()
        let item = SummaryDetailFormItem().onImageTapped({
            // Then
            expectation.fulfill()
        })

        // When
        item.configure(view)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            let actions = view.thumbnailView.actions(forTarget: item, forControlEvent: .primaryActionTriggered)
            actions?.forEach({
                item.perform(NSSelectorFromString($0))
            })
        }

        self.wait(for: [expectation], timeout: 2)
    }
    
}
