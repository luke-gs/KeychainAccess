//
//  StepperFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit


class StepperFormItemTests: XCTestCase {

    func testThatItInstantiatesWithDefaults() {
        // Given
        let title = "Hello"

        // When
        let item = StepperFormItem(title: title)

        // Then
        XCTAssertEqual(item.title?.sizing().string, title)
        XCTAssertEqual(item.minimumValue, 0)
        XCTAssertEqual(item.maximumValue, 10)
        XCTAssertEqual(item.value, 0)
        XCTAssertEqual(item.stepValue, 1)
        XCTAssertEqual(item.numberOfDecimalPlaces, 0)
        XCTAssertTrue(item.cellType == CollectionViewFormStepperCell.self)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormStepperCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = StepperFormItem()

        // When
        item.title("Hello")
            .value(3)
            .stepValue(1)
            .minimumValue(2)
            .maximumValue(20)
            .numberOfDecimalPlaces(2)
            .customValueFont(.systemFont(ofSize: 22))
            .onValueChanged(nil)

        // Then
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.minimumValue, 2)
        XCTAssertEqual(item.maximumValue, 20)
        XCTAssertEqual(item.value, 3)
        XCTAssertEqual(item.stepValue, 1)
        XCTAssertEqual(item.numberOfDecimalPlaces, 2)
        XCTAssertEqual(item.customValueFont, .systemFont(ofSize: 22))
        XCTAssertNil(item.onValueChanged)
    }

    func testThatItConfiguresView() {
        // Given
        let view = CollectionViewFormStepperCell()
        let item = StepperFormItem(title: "Hello")
            .value(3)
            .stepValue(2)
            .minimumValue(2)
            .maximumValue(20)
            .numberOfDecimalPlaces(2)
            .customValueFont(.systemFont(ofSize: 22))

        // When
        item.configure(view)

        // Then
        XCTAssertEqual(view.titleLabel.text, "Hello")
        XCTAssertEqual(view.stepper.maximumValue, 20)
        XCTAssertEqual(view.stepper.minimumValue, 2)
        XCTAssertEqual(view.stepper.value, 3)
        XCTAssertEqual(view.stepper.stepValue, 2)
    }

    func testThatItReturnsIntrinsicWidth() {
        // Given
        let item = StepperFormItem(title: "Hello")

        // When
        let width = item.intrinsicWidth(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), sectionEdgeInsets: .zero, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(width, 0.0)
    }

    func testThatItReturnsIntrinsicHeight() {
        // Given
        let item = StepperFormItem(title: "Hello")

        // When
        let height = item.intrinsicHeight(in: UICollectionView(frame: .zero, collectionViewLayout: CollectionViewFormLayout()), layout: CollectionViewFormLayout(), givenContentWidth: 200.0, for: UITraitCollection())

        // Then
        XCTAssertGreaterThan(height, 0.0)
    }

    func testThatItAppliesTheme() {
        // Given
        let view = CollectionViewFormStepperCell()
        let theme = ThemeManager.shared.theme(for: .current)
        let item = StepperFormItem(title: "Hello")

        // When
        item.apply(theme: theme, toCell: view)

        // Then
        XCTAssertEqual(view.titleLabel.textColor, theme.color(forKey: .secondaryText))
        XCTAssertEqual(view.textField.textColor, theme.color(forKey: .primaryText))
    }

    func testThatItCallsOnValueChangedHandler() {
        // Given
        let expectation = XCTestExpectation()
        let view = CollectionViewFormStepperCell()
        let item = StepperFormItem(title: "Hello")
            .onValueChanged { (value) -> (Void) in
                // Then
                expectation.fulfill()
        }

        // When
        item.configure(view)
        item.cell = view

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            view.valueChangedHandler?(10)
        }

        self.wait(for: [expectation], timeout: 0.1)
    }
    
}
