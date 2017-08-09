//
//  MiscTests.swift
//  MPOLKitTests
//
//  Created by Pavel Boryseiko on 9/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class MiscTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testIfStringEmpty() {
        XCTAssertNil("".ifNotEmpty())
    }

    func testIfStringNotEmpty() {
        XCTAssertNotNil("non empty string".ifNotEmpty())
    }
}
