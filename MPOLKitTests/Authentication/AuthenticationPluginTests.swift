//
//  AuthenticationPluginTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Alamofire
import MPOLKit

class AuthenticationPluginTests: XCTestCase {

    let username = "username"
    let password = "password"
    var token: String { return username + password }

    let request = URLRequest(url: URL(string: "http://www.google.com")!)
    var authHeaderBasic: [String: String]? {
        let header = Request.authorizationHeader(user: username, password: password).flatMap{[$0:$1]}
        return header
    }
    var authHeaderToken: [String: String]? {
        return ["Authorization": "\(token) \(token)"]
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAdaptBasicSignedCorrectly() {

        let plugin = AuthenticationPlugin(authenticationMode: .basicAuthentication(username: username, password: password))
        _ = plugin.adapt(request).then { adaptedRequest -> Void in
            XCTAssertNil(self.request.allHTTPHeaderFields)
            XCTAssertNotNil(adaptedRequest.allHTTPHeaderFields)
            
            XCTAssertEqual(adaptedRequest.allHTTPHeaderFields!, self.authHeaderBasic!)
        }
    }

    func testAdaptTokenSignedCorrectly() {
        let plugin = AuthenticationPlugin(authenticationMode: .accessTokenAuthentication(token: OAuthAccessToken(accessToken: token, type: token)))
        _ = plugin.adapt(request).then { adaptedRequest -> Void in
            XCTAssertNil(self.request.allHTTPHeaderFields)
            XCTAssertNotNil(adaptedRequest.allHTTPHeaderFields)
            
            XCTAssertEqual(adaptedRequest.allHTTPHeaderFields!, self.authHeaderToken!)
        }
    }

}
