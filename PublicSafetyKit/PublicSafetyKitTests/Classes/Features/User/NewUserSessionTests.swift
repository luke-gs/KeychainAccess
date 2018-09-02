//
//  UserSessionTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 5/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Unbox


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
        // Start with no session
        UserSession.current.endSession()

        // Hack due to bizarre apple bug with user defaults. Use our own suite, and clear it on each launch
        let suiteName = "NewUserSessionTests"
        UserSession.userDefaults.removePersistentDomain(forName: suiteName)
        UserSession.userDefaults = UserDefaults(suiteName: suiteName)!

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSessionIsActive() {
        XCTAssertFalse(UserSession.current.isActive)

        UserSession.startSession(user: user, token: token)
        XCTAssertTrue(UserSession.current.isActive)
    }

    func testSessionUser() {
        XCTAssertNil(UserSession.current.user?.username)

        UserSession.startSession(user: user, token: token)
        XCTAssertEqual(user.username, UserSession.current.user?.username)
    }

    func testSessionRecentlyViewedIsEmpty() {
        XCTAssertEqual([], UserSession.current.recentlyViewed.entities)

        UserSession.startSession(user: user, token: token)
        XCTAssertEqual([], UserSession.current.recentlyViewed.entities)
    }

    func testSessionRecentlySearchedIsEmpty() {
        XCTAssertEqual([], UserSession.current.recentlyViewed.entities)

        UserSession.startSession(user: user, token: token)
        XCTAssertEqual([], UserSession.current.recentlySearched)
    }

    func testSessionIDExists() {
        XCTAssertNil(UserSession.current.sessionID)

        UserSession.startSession(user: user, token: token)
        let testID = UserSession.userDefaults.string(forKey: "LatestSessionKey")
        XCTAssertEqual(testID, UserSession.current.sessionID)
    }

    func testPrepareForSession() {
        XCTAssertNil(UserSession.current.sessionID)

        UserSession.prepareForSession()
        let testID = UserSession.userDefaults.string(forKey: "LatestSessionKey")
        XCTAssertEqual(testID, UserSession.current.sessionID)
    }

}
