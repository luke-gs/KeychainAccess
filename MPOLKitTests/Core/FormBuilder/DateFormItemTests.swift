//
//  DateFormItemTests.swift
//  MPOLKitTests
//
//  Created by KGWH78 on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class DateFormItemTests: XCTestCase {

    func testThatItInstantiatesWithDefaults() {
        // Given
        let item = DateFormItem()

        // When
        let mode = item.datePickerMode

        // Then
        XCTAssertTrue(mode == .date)
    }

    func testThatItInstantiatesWithTitle() {
        // Given
        let item = DateFormItem(title: "Hello")

        // When
        let title = item.title

        // Then
        XCTAssertEqual(title?.sizing().string, "Hello")
    }

    func testThatItChains() {
        // Given
        let item = DateFormItem()
        let minDate = Date(timeIntervalSince1970: 0)
        let maxDate = Date()

        // When
        item.minimumDate(minDate)
            .maximumDate(maxDate)
            .datePickerMode(.time)
            .dateFormatter(.formDate)
            .locale(Locale(identifier: "de"))
            .timeZone(TimeZone(secondsFromGMT: 3600))

        // Then
        XCTAssertEqual(item.minimumDate, minDate)
        XCTAssertEqual(item.maximumDate, maxDate)
        XCTAssertEqual(item.datePickerMode, .time)
        XCTAssertEqual(item.locale, Locale(identifier: "de"))
        XCTAssertEqual(item.timeZone, TimeZone(secondsFromGMT: 3600))
        XCTAssertNotNil(item.formatter)
    }
    
}
