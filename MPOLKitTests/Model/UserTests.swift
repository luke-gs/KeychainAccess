//
//  User.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class UserTests: XCTestCase {
    
    func testSupportsSecureCoding() {
        let supports = User.supportsSecureCoding
        XCTAssert(supports == true)
    }
    
    func testBinarySerialization() {
        let user = User(username: "Herli")
        user.termsAndConditionsVersionAccepted = "1"
            
        let cloned = self.clone(object: user)
        XCTAssert(user == cloned)
    }
    
}

