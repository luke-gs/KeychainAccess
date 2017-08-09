//
//  EpochDateTransformerTests.swift
//  MPOLKitTests
//
//  Created by Pavel Boryseiko on 9/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

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
