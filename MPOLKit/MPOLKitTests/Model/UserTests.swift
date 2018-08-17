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
        XCTAssertTrue(supports)
    }
    
    func testBinarySerialization() {
        let user = User(username: "Herli")
        user.setAppSettingValue("1" as AnyObject, forKey: .termsAndConditionsVersionAccepted)
            
        let cloned = self.clone(object: user)
        XCTAssertEqual(user, cloned)
    }
    
    func testThatItNotEqualToUser() {
        let user1 = User(username: "Herli")
        user1.setAppSettingValue("2" as AnyObject, forKey: .termsAndConditionsVersionAccepted)
        
        let user2 = User(username: "Not Herli")
        user2.setAppSettingValue("1" as AnyObject, forKey: .termsAndConditionsVersionAccepted)
        
        XCTAssertNotEqual(user1, user2)
    }
    
    func testThatItNotEqualToAPerson() {
        let user1 = User(username: "Herli")
        user1.setAppSettingValue("10" as AnyObject, forKey: .termsAndConditionsVersionAccepted)
        
        let james = NSObject()
        
        XCTAssertNotEqual(user1, james)
    }

    func testThatDecodingRandomStuffIsNotWorking() {
        
        let something = NSObject()
    
        let data = Data()
        let user = User(coder: NSKeyedUnarchiver(forReadingWith: data))
        
        XCTAssertNotEqual(user, something)
    }
    
    func testThatItCreatesUserSuccessfully() {
        // Given
        let username = "herli"
        
        // When
        let user = User(username: username)
        
        // Then
        let expectedResult = "herli"
        let actualResult = user.username
        XCTAssertEqual(actualResult, expectedResult)
    }
    
}

