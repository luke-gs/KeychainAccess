//
//  PickerFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class PickerFormItemTests: XCTestCase {

    class FakeAction: ValueSelectionAction<String> {
        override func viewController() -> UIViewController {
            return UIViewController()
        }
    }


    func testThatItInstantiatesWithDefaults() {
        // Given
        let action = FakeAction()

        // When
        let item = PickerFormItem(pickerAction: action)

        // Then
        XCTAssertTrue(item.cellType == CollectionViewFormValueFieldCell.self)
        XCTAssertEqual(item.reuseIdentifier, PickerFormItem<String>.defaultReuseIdentifier)
        XCTAssertTrue(item.selectionAction is FakeAction)
        XCTAssertEqual(item.imageSeparation, CellImageLabelSeparation)
        XCTAssertEqual(item.labelSeparation, CellTitleSubtitleSeparation)
    }

    func testThatItChains() {
        // Given
        let item = PickerFormItem(pickerAction: FakeAction())


        // When
        item.title("Hello")
            .pickerTitle("Choose one")
            .selectedValue("Hi")
            .placeholder("Hi")
            .formatter(nil)
            .image(AssetManager.shared.image(forKey: .info))
            .notRequired()
            .required()
            .imageSeparation(10.0)
            .labelSeparation(15.0)
            .onValueChanged(nil)

        // Then
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.selectedValue, "Hi")
        XCTAssertEqual(item.placeholder?.sizing().string, "Hi")
        XCTAssertEqual(item.image, AssetManager.shared.image(forKey: .info))
        XCTAssertEqual(item.isRequired, true)
        XCTAssertEqual(item.imageSeparation, 10.0)
        XCTAssertEqual(item.labelSeparation, 15.0)
        XCTAssertNil(item.onValueChanged)
        XCTAssertNil(item.formatter)
    }

    func testThatItConfiguresView() {
        // Given
        let view = CollectionViewFormValueFieldCell()
        let item = PickerFormItem(pickerAction: FakeAction())
            .title("Hello")
            .image(AssetManager.shared.image(forKey: .info))
            .placeholder("Choose One")

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.valueLabel.text, nil)
        XCTAssertEqual(view.placeholderLabel.text, "Choose One")
        XCTAssertEqual(view.imageView.image, AssetManager.shared.image(forKey: .info))
    }

    func testThatItConfiguresViewWithRequired() {
        // Given
        let view = CollectionViewFormValueFieldCell()
        let item = PickerFormItem(pickerAction: FakeAction())
            .required()
            .title("Hello")

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.titleLabel.text, "Hello*")
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = PickerFormItem(pickerAction: FakeAction())
            .required()
            .title("Hello")

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = PickerFormItem(pickerAction: FakeAction())
            .required()
            .title("Hello")

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormValueFieldCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = PickerFormItem(pickerAction: FakeAction())
            .required()
            .title("Hello")

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.valueLabel.textColor, theme.color(forKey: .primaryText))
    }

    
}
