//
//  EpochDateTransformerTests.swift
//  MPOLKitTests
//
//  Created by Pavel Boryseiko on 9/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest


class EpochDateTransformerTests: XCTestCase {

    lazy var testValue: Double = { return Double(arc4random_uniform(UInt32.max)) }()
    lazy var testDate: Date = { return Date(timeIntervalSince1970: self.testValue) }()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTransform() {
        let date = EpochDateTransformer.shared.transform(testValue)
        XCTAssertEqual(testDate, date)
    }

    func testReverse() {
        let value = EpochDateTransformer.shared.reverse(testDate)
        XCTAssertEqual(testValue, value)
    }
}

class EpochDateTransformerUnboxTests: XCTestCase {

    lazy var testValue: Double = { return Double(arc4random_uniform(UInt32.max)) }()
    lazy var testDate: Date = { return Date(timeIntervalSince1970: self.testValue) }()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFormat() {
        let date = EpochDateTransformer.shared.format(unboxedValue: String(testValue))
        XCTAssertEqual(testDate, date)
    }
}

