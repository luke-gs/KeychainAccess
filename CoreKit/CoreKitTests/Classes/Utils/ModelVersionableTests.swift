//
//  ModelVersionableTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest


class TestVersionable: ModelVersionable { }

class ModelVersionableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testVersion() {
        XCTAssertEqual(TestVersionable.modelVersion, 0)
    }
}

