//
//  MiscTests.swift
//  MPOLKitTests
//
//  Created by Pavel Boryseiko on 9/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class StringEmptyFilteringTests: XCTestCase {

    func testIfStringEmpty() {
        XCTAssertNil("".ifNotEmpty())
    }

    func testIfStringNotEmpty() {
        XCTAssertNotNil("non empty string".ifNotEmpty())
    }
}

class ISO8601DateTransformerTests: XCTestCase {

    //    func testTransform() {
    //        //BULLSHIT test
    //        let testDate = Date()
    //        let string = ISO8601DateTransformer.shared.reverse(testDate)
    //        let date = ISO8601DateTransformer.shared.transform(string)
    //
    //        XCTAssertEqual(testDate, date)
    //    }

    func testReverse() {
        let testDateString = "2017-08-09T03:44:15Z"
        let date = ISO8601DateTransformer.shared.transform(testDateString)
        let string = ISO8601DateTransformer.shared.reverse(date)

        XCTAssertEqual(testDateString, string)
    }

//    func testUnboxFormat() {
//        //BULLSHIT test
//        let testDate = Date()
//        let string = ISO8601DateTransformer.shared.reverse(testDate)
//        let date = ISO8601DateTransformer.shared.format(unboxedValue: string ?? "")
//
//        XCTAssertEqual(testDate, date)
//    }
}
