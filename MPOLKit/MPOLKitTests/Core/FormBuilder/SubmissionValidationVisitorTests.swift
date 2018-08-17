//
//  SubmissionValidationVisitorTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class SubmissionValidationVisitorTests: XCTestCase {

    func testThatItInstantiatesWithDefaults() {
        // Given
        let visitor = SubmissionValidationVisitor()

        // When
        let result = visitor.result

        // Then
        XCTAssertEqual(result, .valid)
    }

    func testThatItIsInvalid() {
        // Given
        let item = TextFieldFormItem().required()
        let visitor = SubmissionValidationVisitor()

        // When
        item.accept(visitor)

        // Then
        XCTAssertFalse(visitor.result.isValid())
    }

}
