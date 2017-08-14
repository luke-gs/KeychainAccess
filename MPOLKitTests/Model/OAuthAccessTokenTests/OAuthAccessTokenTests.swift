//
//  OAuthAccessTokenTests.swift
//  MPOLKit
//
//  Created by Herli Halim on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit
import Unbox

class OAuthAccessTokenTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSupportsSecureCoding() {
        let supports = OAuthAccessToken.supportsSecureCoding
        XCTAssertTrue(supports)
    }
    
    func testBinarySerialization() {
        let token = OAuthAccessToken(accessToken: "24", type: "grant", expiresAt: Date(), refreshToken: "3242", refreshTokenExpiresAt: Date())
        let cloned = self.clone(object: token)
        
        print(cloned)
        
        XCTAssertEqual(token, cloned)
    }
    
    func testThatItNotEqualToToken() {
        let token = OAuthAccessToken(accessToken: "24", type: "grant", expiresAt: Date(), refreshToken: "3242", refreshTokenExpiresAt: Date())
        let token2 = OAuthAccessToken(accessToken: "242", type: "grant", expiresAt: Date(), refreshToken: "3242", refreshTokenExpiresAt: Date())
        XCTAssertNotEqual(token, token2)
    }
    
    func testThatItNotEqualToOtherObject() {
        let token = OAuthAccessToken(accessToken: "24", type: "grant", expiresAt: Date(), refreshToken: "3242", refreshTokenExpiresAt: Date())
        let object = NSObject()
        
        XCTAssertNotEqual(token, object)
    }
    
    func testThatDecodingRandomStuffIsNotWorking() {
        
        let something = NSObject()
        
        let data = Data()
        let token = OAuthAccessToken(coder: NSKeyedUnarchiver(forReadingWith: data))
        
        XCTAssertNotEqual(token, something)
    }

    func testThatItDeserialiseFromJSONCorrectly() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "OAuthAccessToken", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! UnboxableDictionary
        
        let token: OAuthAccessToken = try! unbox(dictionary: json)
        
        XCTAssertNotNil(token)
        
        XCTAssertEqual(token.accessToken, json["access_token"] as! String)
        XCTAssertEqual(token.type, json["token_type"] as! String)
        XCTAssertEqual(token.expiresAt!.timeIntervalSince1970, TimeInterval(json["access_token_expiry_time"] as! String))
        XCTAssertEqual(token.refreshTokenExpiresAt!.timeIntervalSince1970, TimeInterval(json["refresh_token_expiry_time"] as! String))
        XCTAssertEqual(token.refreshToken!, json["refresh_token"] as! String)
    }
    
    func testThatItWillFailIfRequiredAccessTokenFieldIsMissingFromJSON() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "OAuthAccessToken", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        var json = try! JSONSerialization.jsonObject(with: data, options: []) as! UnboxableDictionary
        
        json.removeValue(forKey: "access_token")
        
        XCTAssertNoThrow({
            _ = try! unbox(dictionary: json) as OAuthAccessToken
        })

    }
    
    func testThatItWillFailIfRequiredTypeFieldIsMissingFromJSON() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "OAuthAccessToken", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        var json = try! JSONSerialization.jsonObject(with: data, options: []) as! UnboxableDictionary
        
        json.removeValue(forKey: "token_type")
        
        XCTAssertNoThrow({
            _ = try! unbox(dictionary: json) as OAuthAccessToken
        })
        
    }
    
}
