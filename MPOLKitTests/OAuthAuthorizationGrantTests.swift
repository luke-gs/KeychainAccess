//
//  OAuthAuthorizationGrantTests.swift
//  MPOLKitTests
//
//  Created by Pavel Boryseiko on 9/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class OAuthAuthorizationGrantTests: XCTestCase {

    let username = "username"
    let password = "password"
    var refreshToken: String { return username + password }

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testOAuthGrantCredentials() {
        let grant: OAuthAuthorizationGrant = .credentials(username: username, password: password)
        let testDict = ["grant_type": "password", "username": username, "password": password]

        testDict.forEach { pair in
            if let value = grant.parameters[pair.key] as? String {
                XCTAssertEqual(pair.value, value)
            } else {
                XCTFail("Key \(pair.key) not found")
            }
        }
    }
    func testOAuthGrantRefresh() {
        let grant: OAuthAuthorizationGrant = .refreshToken(refreshToken)
        let testDict = ["grant_type": "refresh_token", "refresh_token": refreshToken]

        testDict.forEach { pair in
            if let value = grant.parameters[pair.key] as? String {
                XCTAssertEqual(pair.value, value)
            } else {
                XCTFail("Key \(pair.key) not found")
            }
        }
    }
}
