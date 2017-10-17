//
//  ReloadValidationStateVisitorTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ReloadValidationStateVisitorTests: XCTestCase {
    
    func testThatItUpdatesItemsValidationState() {
        // Given
        let item = TextFieldFormItem().required()
        let visitor = ReloadValidationStateVisitor()

        // When
        item.accept(visitor)

        // Then
        XCTAssertEqual(item.focusedText, FormRequired.default.message)
    }
    
}
