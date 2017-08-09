//
//  AuthenticationHeaderAdapterTests.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 9/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Alamofire
@testable import MPOLKit

class AuthenticationHeaderAdapterTests: XCTestCase {

    let username = "username"
    let password = "password"
    var token: String { return username + password }

    let testRequest = URLRequest(url: URL(string: "http://www.google.com")!)
    var authHeader: [String: String]? {
        let dict = Request.authorizationHeader(user: username, password: password).flatMap{[$0:$1]}
        return dict
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testHTTPAuthenticationModeBasicEquality() {
        let mode1: HTTPAuthenticationMode = .basicAuthentication(username: username, password: password)
        let mode2: HTTPAuthenticationMode = .basicAuthentication(username: username, password: password)

        XCTAssertEqual(mode1, mode2)
    }

    func testHTTPAuthenticationModeTokenEquality() {
        let mode1: HTTPAuthenticationMode = .accessTokenAuthentication(token: OAuthAccessToken(accessToken: token, type: token))
        let mode2: HTTPAuthenticationMode = .accessTokenAuthentication(token: OAuthAccessToken(accessToken: token, type: token))

        XCTAssertEqual(mode1, mode2)
    }

    func testHTTPAuthenticationModeBasicInEquality() {
        let mode1: HTTPAuthenticationMode = .basicAuthentication(username: password, password: username)
        let mode2: HTTPAuthenticationMode = .basicAuthentication(username: username, password: password)

        XCTAssertNotEqual(mode1, mode2)
    }

    func testAdaptNoNil() {
        let adapter1 = AuthenticationHeaderAdapter(authenticationMode: .basicAuthentication(username: username, password: password))
        let adaptedRequest = try! adapter1.adapt(testRequest)

        XCTAssertNil(testRequest.allHTTPHeaderFields)
        XCTAssertNotNil(adaptedRequest.allHTTPHeaderFields)

        XCTAssertEqual(adaptedRequest.allHTTPHeaderFields!, authHeader!)
    }

    func testAdaptCorrectHeader() {
        let adapter1 = AuthenticationHeaderAdapter(authenticationMode: .basicAuthentication(username: username, password: password))
        let adaptedRequest = try! adapter1.adapt(testRequest)

        XCTAssertEqual(adaptedRequest.allHTTPHeaderFields!, authHeader!)
    }
}

