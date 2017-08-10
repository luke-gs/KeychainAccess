//
//  OAuthAccessTokenTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Unbox
@testable import MPOLKit

class OAuthAccessTokenTests: XCTestCase {

    lazy var testValue: Double = { return Double(arc4random_uniform(UInt32.max)) }()
    lazy var testDate: Date = { return Date(timeIntervalSince1970: self.testValue) }()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testUnboxer() {
        let data: [String: Any] = ["token_type": "type",
                                   "access_token": "asdkqaidhlasbkj",
                                   "access_token_expiry_time": testDate,
                                   "refresh_token": "asdasdoiuasldnk",
                                   "refresh_token_expiry_time": testDate]
        
        let boxer = Unboxer(dictionary: data)
        
        let result = try! OAuthAccessToken(unboxer: boxer)

        XCTAssertEqual((data["token_type"] as! String), result.type)
        XCTAssertEqual((data["access_token"] as! String), result.accessToken)
        XCTAssertEqual((data["refresh_token"] as! String), result.refreshToken)

//        Fix this later
//        XCTAssertEqual((data["refresh_token_expiry_time"] as! Date), result.refreshTokenExpiresAt)
//        XCTAssertEqual((data["access_token_expiry_time"] as! Date), result.expiresAt)
    }


    func testSupportsSecureCoding() {
        let supports = OAuthAccessToken.supportsSecureCoding
        XCTAssertTrue(supports)
    }

    func testBinarySerialization() {
        let token = OAuthAccessToken(accessToken: "asdasdas",
                                     type: "asdasdas",
                                     expiresAt: Date(),
                                     refreshToken: "asdasdasd",
                                     refreshTokenExpiresAt: Date())
        let cloned = self.clone(object: token)

        XCTAssertTrue(token == cloned)
    }
}

