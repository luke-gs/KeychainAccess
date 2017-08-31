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

class FileManagerTests: XCTestCase {

    func testFileExists() {
        if let url = Bundle(for: type(of: self)).url(forResource: "testTheme", withExtension: "json") {
            XCTAssertTrue(FileManager.default.fileExists(at: url))
        }
    }
    func testFileDoesntExist() {
        if let url = Bundle(for: type(of: self)).url(forResource: "testTheme", withExtension: "json")?.appendingPathComponent("doesntExist") {
            print(url.absoluteString)
            XCTAssertFalse(FileManager.default.fileExists(at: url))
        }
    }
}

class UIFontConvenience: XCTestCase {

    let font = UIFont.systemFont(ofSize: 10)

    func testInfiniteNumberOfLines() {
        XCTAssertEqual(font.height(forNumberOfLines: 0), .greatestFiniteMagnitude)
    }

    func testSingleLine() {
        XCTAssertEqual(font.height(forNumberOfLines: 1), font.lineHeight)
    }

    func testMultiLine() {
        let numberofLines = 3
        //Magic numbers time
        let test = (font.lineHeight + font.leading) * CGFloat(numberofLines) - font.leading
        XCTAssertEqual(font.height(forNumberOfLines: numberofLines), test)
    }
}
