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
        UserSession.startSession(user: user, token: token)
        XCTAssertTrue(UserSession.current.isActive)
    }

    func testSessionUser() {
        UserSession.startSession(user: user, token: token)
        XCTAssertEqual(user.username, UserSession.current.user?.username)
    }

    func testSessionRecentlyViewedIsEmpty() {
        UserSession.startSession(user: user, token: token)
        XCTAssertEqual([], UserSession.current.recentlyViewed.entities)
    }

    func testSessionRecentlySearchedIsEmpty() {
        UserSession.startSession(user: user, token: token)
        XCTAssertEqual([], UserSession.current.recentlySearched)
    }

    func testSessionIDExists() {
        UserSession.startSession(user: user, token: token)
        let testID = UserDefaults.standard.string(forKey: "LatestSessionKey")
        XCTAssertEqual(testID, UserSession.current.sessionID)
    }
}
