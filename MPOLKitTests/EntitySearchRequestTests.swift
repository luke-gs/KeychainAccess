//
//  EntitySearchRequestTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class EntitySearchRequestTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testParams() {
        let testData: [String: Any] = ["test": "data", "test2": 100]
        let request = EntitySearchRequest<MPOLKitEntity>(parameters: testData)

        XCTAssertEqual(testData["test"] as! String, request.parameters["test"] as! String)
        XCTAssertEqual(testData["test2"] as! Int, request.parameters["test2"] as! Int)
    }
}

