//
//  RangeFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class RangeFormItemTests: XCTestCase {
    
    func testThatItInstantiatesWithDefaults() {
        // Given
        let item = RangeFormItem()

        // When
        let range = item.range

        // Then
        XCTAssertEqual(range, 0...1)
    }

    func testThatItInstantiatesWithTitle() {
        // Given
        let item = RangeFormItem(title: "Hello")

        // When
        let title = item.title

        // Then
        XCTAssertEqual(title?.sizing().string, "Hello")
    }

    func testThatItChains() {
        // Given
        let item = RangeFormItem()

        // When
        item.range(10...100)

        // Then
        XCTAssertEqual(item.range, 10...100)
    }

}
