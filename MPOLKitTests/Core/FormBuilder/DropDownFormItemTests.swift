//
//  DropDownFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class DropDownFormItemTests: XCTestCase {

    func testThatItInstantiatesWithTitle() {
        // Given
        let item = DropDownFormItem<String>(title: "Hello")

        // When
        let title = item.title

        // Then
        XCTAssertEqual(title?.sizing().string, "Hello")
    }

    func testThatItChains() {
        // Given
        let item = DropDownFormItem<String>(title: "Hello")

        // When
        item.options(["Hello", "Bye"])
            .allowsMultipleSelection(true)

        // Then
        XCTAssertEqual(item.options, ["Hello", "Bye"])
        XCTAssertTrue(item.allowsMultipleSelection)
    }
    
}
