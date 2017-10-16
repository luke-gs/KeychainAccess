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
    
    func testThatItInstantiatesWithDefaults() {
        // Given
        let title = "Hello"
        let options = ["Hi", "Bye"]
        let action = PickerAction(title: title, options: options)

        // When
        let item = PickerFormItem(pickerAction: action)

        // Then
        XCTAssertTrue(item.cellType == CollectionViewFormValueFieldCell.self)
        XCTAssertEqual(item.reuseIdentifier, PickerFormItem<[String]>.defaultReuseIdentifier)
        XCTAssertTrue(item.selectionAction is PickerAction<String>)
        XCTAssertEqual(item.imageSeparation, CellImageLabelSeparation)
        XCTAssertEqual(item.labelSeparation, CellTitleSubtitleSeparation)
    }

    func testThatItChains() {
        // Given
        let item = PickerFormItem<[String]>()

        // When
        item.title("Hello")
            .value("Bye")
            .placeholder("Hi")
            .image(AssetManager.shared.image(forKey: .info))
            .notRequired()
            .required()
            .imageSeparation(10.0)
            .labelSeparation(15.0)
            .pickerAction(PickerAction(title: "Hello", options: ["Wow", "Mom"]))
            .onValueChanged(nil)

        // Then
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.value?.sizing().string, "Bye")
        XCTAssertEqual(item.placeholder?.sizing().string, "Hi")
        XCTAssertEqual(item.image, AssetManager.shared.image(forKey: .info))
        XCTAssertEqual(item.isRequired, true)
        XCTAssertEqual(item.imageSeparation, 10.0)
        XCTAssertEqual(item.labelSeparation, 15.0)
        XCTAssertNil(item.onValueChanged)
    }

    func testThatItConfiguresView() {
        // Given
        let view = CollectionViewFormValueFieldCell()
        let item = PickerFormItem(pickerAction: PickerAction(title: "Hello", options: ["Hi", "Bye"]))
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
        let item = PickerFormItem(pickerAction: PickerAction(title: "Hello", options: ["Hi", "Bye"])).required()

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.titleLabel.text, "Hello*")
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = PickerFormItem(pickerAction: PickerAction(title: "Hello", options: ["Hi", "Bye"])).required()

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = PickerFormItem(pickerAction: PickerAction(title: "Hello", options: ["Hi", "Bye"])).required()

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormValueFieldCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = PickerFormItem(pickerAction: PickerAction(title: "Hello", options: ["Hi", "Bye"])).required()

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.valueLabel.textColor, theme.color(forKey: .primaryText))
    }

    
}
