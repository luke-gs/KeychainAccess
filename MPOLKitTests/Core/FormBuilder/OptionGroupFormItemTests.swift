//
//  OptionGroupFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 16/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit


class OptionGroupFormItemTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // Given
        let optionStyle = CollectionViewFormOptionCell.OptionStyle.checkbox
        let options = ["Hello", "Bye"]

        // When
        let item = OptionGroupFormItem(optionStyle: optionStyle, options: options)

        // Then
        XCTAssertEqual(item.optionStyle, .checkbox)
        XCTAssertEqual(item.options, options)
        XCTAssertEqual(item.selectedIndexes, IndexSet())
        XCTAssertTrue(item.cellType == CollectionViewFormOptionCell.self)
        XCTAssertEqual(item.reuseIdentifier, CollectionViewFormOptionCell.defaultReuseIdentifier)
    }

    func testThatItChains() {
        // Given
        let item = OptionGroupFormItem(optionStyle: .radio, options: ["Hello", "Bye"])

        // When
        item.title("Hello")
            .options(["New", "New 2"])
            .imageSeparation(30.0)
            .labelSeparation(40.0)
            .notRequired()
            .required()
            .selectedIndexes(IndexSet(integer: 0))
            .onValueChanged(nil)

        // Then
        XCTAssertEqual(item.optionStyle, .radio)
        XCTAssertEqual(item.title?.sizing().string, "Hello")
        XCTAssertEqual(item.options, ["New", "New 2"])
        XCTAssertEqual(item.isRequired, true)
        XCTAssertEqual(item.imageSeparation, 30.0)
        XCTAssertEqual(item.labelSeparation, 40.0)
        XCTAssertEqual(item.selectedIndexes, IndexSet(integer: 0))
        XCTAssertNil(item.onValueChanged)
    }

    func testThatItGeneratesItems() {
        // Given
        let item = OptionGroupFormItem(optionStyle: .radio, options: ["Hello", "Hi"]).title("Hello")

        // When
        let subItems = item.items

        // Then
        XCTAssertEqual(subItems.count, 3)
    }

    func testThatItReturnsSelectedIndexesAsCandidate() {
        // Given
        let item = OptionGroupFormItem(optionStyle: .radio, options: ["Hello", "Hi"])

        // When
        let candidate = item.candidate

        // Then
        XCTAssertEqual(item.selectedIndexes, candidate as! IndexSet)
    }

}
