//
//  UserSessionTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Unbox
import KeychainSwift
@testable import MPOLKit

private var user = User(username: "Blahblah")
private var token: OAuthAccessToken {
    let bundle = Bundle(for: NewUserSessionTests.self)
    let url = bundle.url(forResource: "OAuthAccessToken", withExtension: "json")

    let data = try! Data(contentsOf: url!)
    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! UnboxableDictionary

    let token: OAuthAccessToken = try! unbox(dictionary: json)

    return token
}

class NewUserSessionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSessionIsActive() {
        let expectation = XCTestExpectation(description: "Session should be active")
        UserSession.startSession(user: user, token: token) { success in
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(UserSession.current.isActive)
    }

    func testSessionUser() {
        let expectation = XCTestExpectation(description: "Users should be the same")
        UserSession.startSession(user: user, token: token) { success in
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(user.username, UserSession.current.user?.username)
    }

    func testSessionRecentlyViewedIsEmpty() {
        let expectation = XCTestExpectation(description: "Recently Viewed should be added successfully")
        UserSession.startSession(user: user, token: token) { success in
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual([], UserSession.current.recentlyViewed)
    }

    func testSessionRecentlySearchedIsEmpty() {
        let expectation = XCTestExpectation(description: "Recently searched should be added successfully")
        UserSession.startSession(user: user, token: token) { success in
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual([], UserSession.current.recentlySearched)
    }

    func testSessionIDExists() {
        let expectation = XCTestExpectation(description: "Session ID should exist")
        UserSession.startSession(user: user, token: token) { success in
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 5.0)
        let testID = UserDefaults.standard.string(forKey: "LatestSessionKey")
        XCTAssertEqual(testID, UserSession.current.sessionID)
    }
}
