//
//  KeyboardInputManagerTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class KeyboardInputManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        KeyboardInputManager.shared.isNumberBarEnabled = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testIsNumberBarSupported() {
        XCTAssertTrue(KeyboardInputManager.shared.isNumberBarSupported)
    }

    func testIsNumberBarDisabledByDefault() {
        let defaultValue = UserDefaults.mpol.bool(forKey: "isNumberBarEnabled")
        XCTAssertEqual(defaultValue, KeyboardInputManager.shared.isNumberBarEnabled)
    }

    func testIsNumberBarEnabled() {
        KeyboardInputManager.shared.isNumberBarEnabled = true
        let defaultValue = UserDefaults.mpol.bool(forKey: "isNumberBarEnabled")
        XCTAssertEqual(defaultValue, KeyboardInputManager.shared.isNumberBarEnabled)
    }
}

