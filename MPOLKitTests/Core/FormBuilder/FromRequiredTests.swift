//
//  FromRequiredTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class FromRequiredTests: XCTestCase {

    func testThatItHasCorrectDefaults() {
        // Given
        let formRequired = FormRequired.default

        // When
        let message = formRequired.message
        let symbol = formRequired.symbol
        let requiredPlaceholder = formRequired.requiredPlaceholder
        let notRequiredPlaceholder = formRequired.notRequiredPlaceholder
        let color = formRequired.color
        let dropdownAction = formRequired.dropDownAction

        // Thene
        XCTAssertEqual(message, "This is required.")
        XCTAssertEqual(symbol, "*")
        XCTAssertEqual(requiredPlaceholder, "Required")
        XCTAssertEqual(notRequiredPlaceholder, "Optional")
        XCTAssertEqual(dropdownAction, "Select")
        XCTAssertEqual(color, UIColor(red: 1.0, green: 59.0 / 255.0, blue: 48.0 / 255, alpha: 1.0))
    }

    func testThatIsReturnsCorrectPlacholder() {
        // Given
        let formRequired = FormRequired.default

        // When
        let requiredText = formRequired.placeholder(withRequired: true)
        let notRequiredText = formRequired.placeholder(withRequired: false)

        // Then
        XCTAssertEqual(requiredText, "Required")
        XCTAssertEqual(notRequiredText, "Optional")
    }

}
