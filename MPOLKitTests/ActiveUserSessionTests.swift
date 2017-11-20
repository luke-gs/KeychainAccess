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

class ActiveUserSessionTests: XCTestCase {
    static var initialSetupComplete = false

    override static func setUp() {
        User.applicationKey = "Test"
        UserSession.current.endSession()
        UserSession.startSession(user: user, token: token)
    }

    let testEntity = MPOLKitEntity(id: "1234123")
    lazy var testSearchable: Searchable = {
        let searchable = Searchable()
        searchable.type = "testType"
        return searchable
    }()

    func testSessionRecentlyViewed() {
        UserSession.current.recentlyViewed = [testEntity]
        XCTAssertEqual([testEntity], UserSession.current.recentlyViewed)
    }

    func testSessionRecentlySearched() {
        UserSession.current.recentlySearched = [testSearchable]
        XCTAssertEqual([testSearchable], UserSession.current.recentlySearched)
    }

    func testRestoreSession() {
        let expectation = XCTestExpectation(description: "Session should be restored successfully")

        UserSession.current.recentlyViewed = [testEntity]
        UserSession.current.recentlySearched = [testSearchable]

        UserSession.current.restoreSession { token in
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)

        XCTAssertEqual(user.username, UserSession.current.user?.username)
        XCTAssertEqual(testSearchable.type, UserSession.current.recentlySearched.first?.type)
        XCTAssertEqual(testEntity.id, UserSession.current.recentlyViewed.first?.id)
    }

    func testUserUpdateTC() {
        UserSession.current.user?.termsAndConditionsVersionAccepted = "1234"
        UserSession.current.updateUser()
        XCTAssertEqual("1234", UserSession.current.user?.termsAndConditionsVersionAccepted)
    }

    func testUserUpdateWhatsNew() {
        UserSession.current.user?.whatsNewShownVersion = "1234"
        UserSession.current.updateUser()
        XCTAssertEqual("1234", UserSession.current.user?.whatsNewShownVersion)
    }
}
