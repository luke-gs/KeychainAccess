//
//  LookupAddressTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 23/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
import Unbox
import MPOLKit
import CoreLocation

class LookupAddressTests: XCTestCase {

    func testThatItDeserialiseFromJSONCorrectly() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "LookupAddress", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! UnboxableDictionary

        let address = try! unbox(dictionary: json) as LookupAddress

        XCTAssertNotNil(address)

        XCTAssertEqual(address.id, json["id"] as! String)
        XCTAssertEqual(address.fullAddress, json["fullAddress"] as! String)
        XCTAssertEqual(address.isAlias, json["isAlias"] as! Bool)
        XCTAssertEqual(address.coordinate.longitude, json["longitude"] as! CLLocationDegrees)
        XCTAssertEqual(address.coordinate.longitude, json["latitude"] as! CLLocationDegrees)
    }

    func testThatItWillNotDeserialiseFromIncorrectJSON() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "LookupAddress", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        var json = try! JSONSerialization.jsonObject(with: data, options: []) as! UnboxableDictionary
        json.removeValue(forKey: "id")

        XCTAssertNoThrow({
            _ = try! unbox(dictionary: json) as LookupAddress
        })
    }
}
