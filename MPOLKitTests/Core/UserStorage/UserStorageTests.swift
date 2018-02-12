//
//  UserStorageTests.swift
//  MPOLKitTests
//
//  Created by Bryan Hathaway on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class UserStorageTests: XCTestCase {

    private static let testUserID = "123"

    private lazy var userStorage: UserStorage = {
        return UserStorage(userID: UserStorageTests.testUserID)
    }()

    // MARK: Add and Retrieve

    func testThatRandomThingsAreStoreAndRetrievable() {
        addAndTestRetrieve(object: "Awesome Object", key: "Luke")
        addAndTestRetrieve(object: 0, key: "is")
        addAndTestRetrieve(object: ["Awesome", "Array"], key: "an")
        addAndTestRetrieve(object: [1, 2], key: "adequate")
        addAndTestRetrieve(object: User(username: "Chad"), key: "iOS")
        addAndTestRetrieve(object: UIView(), key: "developer")

    }

    func testThatSpacedKeysAreFine() {
        addAndTestRetrieve(object: "Awesome Object", key: "Awesome Key")
    }

    func testThatDataIsSegregatedByUserID() {
        let key = "my key not yours"
        addAndTestRetrieve(object: "Segregated Object", key: key)

        let otherUserStorage = UserStorage(userID: "456")
        let potentialData = otherUserStorage.retrieve(key: key)

        XCTAssert(potentialData == nil)
    }

    func testThatDataIsRetrievableWithInstanceFromSameID() {
        let key = "Alicia Keys"
        addAndTestRetrieve(object: "Awesome Object", key: key)

        let alsoMyUserStorage = UserStorage(userID: UserStorageTests.testUserID)
        let potentialData = alsoMyUserStorage.retrieve(key: key)

        XCTAssert(potentialData != nil)
    }

    // MARK: Deletion

    func testThatDeletingWorks() {
        let key = "a key"
        addAndTestRetrieve(object: "Important Data", key: key)

        remove(key: key)
        retrieveAndAssert(key: key, type: String.self, expectsSuccess: false)
    }

    func testThatDeletingNonExistentIsGraceful() {
        let key = "a key that doesn't exist"
        remove(key: key)
        XCTAssert(true)
    }

    func testThatPurgingFlagsWorks() {
        let vehicle = "vehicle"
        let monkey = "monkey"
        let donut = "Donut"
        addAndTestRetrieve(object: "🚔", key: vehicle, flag: .retain)
        addAndTestRetrieve(object: "🐒", key: monkey, flag: .retain)

        addAndTestRetrieve(object: "🍩", key: donut, flag: .session)

        purge(flag: .retain)

        retrieveAndAssert(key: vehicle, type: "", expectsSuccess: false)
        retrieveAndAssert(key: monkey, type: "", expectsSuccess: false)

        retrieveAndAssert(key: donut, type: "", expectsSuccess: true)
    }

    // MARK: Teardown

    override func tearDown() {
        // Clear all UserStorage after each test
        UserStorage.purgeAllUsers()
    }



    // MARK: - Helpers

    func addAndTestRetrieve<T>(object: T, key: String, flag: UserStorageFlag = .session) {
        userStorage.add(object: object, key: key, flag: flag)

        retrieveAndAssert(key: key, type: object)
    }

    @discardableResult
    func retrieveAndAssert<T>(key: String, type: T, expectsSuccess: Bool = true) -> T? {
        let retrieved = userStorage.retrieve(key: key) as? T

        let result = retrieved != nil
        XCTAssert(result == expectsSuccess)

        return retrieved
    }

    func remove(key: String) {
        do {
            try userStorage.remove(key: key)
        } catch {
            XCTAssert(false)
        }
    }

    func purge(flag: UserStorageFlag) {
        do {
            try userStorage.purge(flag: flag)
        } catch {
            XCTAssert(false)
        }
    }

}
