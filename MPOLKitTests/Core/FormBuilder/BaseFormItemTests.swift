//
//  BaseFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class BaseFormItemTests: XCTestCase {

    var item: BaseFormItem!

    override func setUp() {
        super.setUp()
        item = BaseFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: CollectionViewFormSubtitleCell.defaultReuseIdentifier)
    }

    func testThatItCreatesCorrectCell() {
        // When
        let cellType = item.cellType
        let reuseIdentifer = item.reuseIdentifier

        // Then
        XCTAssertTrue(cellType == CollectionViewFormSubtitleCell.self)
        XCTAssertEqual(reuseIdentifer, CollectionViewFormSubtitleCell.defaultReuseIdentifier)
    }

    func testThatItAcceptsVisitor() {
        // Given
        let visitor = SubmissionValidationVisitor()

        // When
        item.accept(visitor)

        // Then
        XCTAssertTrue(visitor.result == .valid)
    }

    func testThatItReturnsCorrectMinimumContentWidthWhenFixedWidthIsUsed() {
        // Given
        item.width = .fixed(300.0)

        // When
        let points = item.minimumContentWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertEqual(points, 300.0)
    }

    func testThatItReturnsCorrectMinimumContentWidthWhenDynamicWidthIsUsed() {
        // Given
        item.width = .dynamic { _ in return 300.0 }
        
        // When
        let points = item.minimumContentWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())
        
        // Then
        XCTAssertEqual(points, 300.0)
    }

    func testThatItReturnsCorrectMinimumContentHeightWhenFixedWidthIsUsed() {
        // Given
        item.height = .fixed(300.0)

        // When
        let points = item.minimumContentHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 500.0, for: UITraitCollection())

        // Then
        XCTAssertEqual(points, 300.0)
    }

    func testThatItReturnsCorrectMinimumContentHeightWhenDynamicWidthIsUsed() {
        // Given
        item.height = .dynamic { _ in return 300.0 }

        // When
        let points = item.minimumContentHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 500.0, for: UITraitCollection())

        // Then
        XCTAssertEqual(points, 300.0)
    }

    func testThatItReturnsValidationAccessoryHeightWhenThereIsAFocusedText() {
        // Given
        item.focusedText = "Error Message"

        // When
        let height = item.heightForValidationAccessory(givenContentWidth: 500.0, for: UITraitCollection())

        // Then
        XCTAssertTrue(height > 10.0)
    }

    func testThatItReturnsZeroValidationAccessoryHeightWhenThereIsNoFocusedText() {
        // Given
        item.focusedText = nil

        // When
        let height = item.heightForValidationAccessory(givenContentWidth: 500.0, for: UITraitCollection())

        // Then
        XCTAssertTrue(height == 0.0)
    }

    func testThatItDecoratesCellsWithSpecifiedColors() {
        // Given
        let cell = CollectionViewFormSubtitleCell()

        item.separatorColor = .blue
        item.separatorTintColor = .green
        item.focusColor = .orange

        // When
        item.decorate(cell, withTheme: ThemeManager.shared.theme(for: .current))

        // Then
        XCTAssertEqual(cell.separatorColor, .blue)
        XCTAssertEqual(cell.separatorTintColor, .green)
        XCTAssertEqual(cell.validationColor, .orange)
    }

    func testThatItOnThemeChangedHappensAfterItDecoratesCellsWithSpecifiedColors() {
        // Given
        let cell = CollectionViewFormSubtitleCell()

        item.separatorColor = .blue
        item.separatorTintColor = .green
        item.focusColor = .orange
        item.onThemeChanged { (cell, theme) in
            cell.separatorColor = .red
            cell.separatorTintColor = .red
            cell.validationColor = .red
        }

        // When
        item.decorate(cell, withTheme: ThemeManager.shared.theme(for: .current))

        // Then
        XCTAssertEqual(cell.separatorColor, .red)
        XCTAssertEqual(cell.separatorTintColor, .red)
        XCTAssertEqual(cell.validationColor, .red)
    }

    /// MARK: - Distributions

    func testThatItCreatesHorizontalDistributionInfo() {
        // Given
        let layout = CollectionViewFormLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let insets = UIEdgeInsets.zero
        let traitCollection = UITraitCollection()

        // When
        let info = BaseFormItem.HorizontalDistribution.Info(collectionView: collectionView, layout: layout, edgeInsets: insets, traitCollection: traitCollection)

        // Then
        XCTAssert(info.collectionView === collectionView)
        XCTAssert(info.layout === layout)
        XCTAssert(info.edgeInsets == .zero)
        XCTAssert(info.traitCollection == traitCollection)
    }

    func testThatItCreatesVerticalDistributionInfo() {
        // Given
        let layout = CollectionViewFormLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let contentWidth: CGFloat = 200.0
        let traitCollection = UITraitCollection()

        // When
        let info = BaseFormItem.VerticalDistribution.Info(collectionView: collectionView, layout: layout, contentWidth: contentWidth, traitCollection: traitCollection)

        // Then
        XCTAssert(info.collectionView === collectionView)
        XCTAssert(info.layout === layout)
        XCTAssert(info.contentWidth == 200.0)
        XCTAssert(info.traitCollection == traitCollection)
    }


    /// MARK: - Chainging tests

    func testThatItChains() {
        // Given
        let item = BaseFormItem(cellType: CollectionViewFormSubtitleCell.self, reuseIdentifier: CollectionViewFormSubtitleCell.defaultReuseIdentifier)

        // When
        item.elementIdentifier("ItemID")
            .reuseIdentifier("ItemReuseIdentifier")
            .accessory(nil)
            .contentMode(.top)
            .selectionStyle(.fade)
            .highlightStyle(.none)
            .separatorStyle(.fullWidth)
            .separatorColor(.red)
            .separatorTintColor(.green)
            .focusColor(.blue)
            .editActions([])
            .focusedText("Focused Text")
            .focused(true)
            .width(.fixed(240.0))
            .height(.fixed(100.0))
            .onConfigured(nil)
            .onThemeChanged(nil)
            .onSelection(nil)

        // Then
        XCTAssertEqual(item.elementIdentifier, "ItemID")
        XCTAssertEqual(item.reuseIdentifier, "ItemReuseIdentifier")
        XCTAssertNil(item.accessory)
        XCTAssertTrue(item.contentMode == .top)
        XCTAssertTrue(item.selectionStyle == .fade)
        XCTAssertTrue(item.highlightStyle == .none)
        XCTAssertTrue(item.separatorStyle == .fullWidth)
        XCTAssertTrue(item.separatorColor == .red)
        XCTAssertTrue(item.separatorTintColor == .green)
        XCTAssertTrue(item.focusColor == .blue)
        XCTAssertTrue(item.editActions.count == 0)
        XCTAssertTrue(item.isFocused)
        XCTAssertNil(item.onConfigured)
        XCTAssertNil(item.onThemeChanged)
        XCTAssertNil(item.onSelection)

        switch item.width {
        case .fixed(let points):
            XCTAssertTrue(points == 240.0)
        default:
            XCTAssert(false, "Incorrect preferred width")
        }

        switch item.height {
        case .fixed(let points):
            XCTAssertTrue(points == 100.0)
        default:
            XCTAssert(false, "Incorrect preferred height")
        }

    }

}
