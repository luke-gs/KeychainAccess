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

        let location: UnboxableDictionary = json["location"] as! UnboxableDictionary

        XCTAssertEqual(address.coordinate.longitude, location["longitude"] as! CLLocationDegrees)
        XCTAssertEqual(address.coordinate.latitude, location["latitude"] as! CLLocationDegrees)

        XCTAssertEqual(address.commonName, location["commonName"] as? String)
        XCTAssertEqual(address.country, location["country"] as? String)
        XCTAssertEqual(address.county, location["county"] as? String)
        XCTAssertEqual(address.floor, location["floor"] as? String)
        XCTAssertEqual(address.lotNumber, location["lotNumber"] as? String)
        XCTAssertEqual(address.postalCode, location["postalCode"] as? String)
        XCTAssertEqual(address.state, location["state"] as? String)
        XCTAssertEqual(address.streetDirectional, location["streetDirectional"] as? String)
        XCTAssertEqual(address.streetName, location["streetName"] as? String)
        XCTAssertEqual(address.streetNumberEnd, location["streetNumberEnd"] as? String)
        XCTAssertEqual(address.streetNumberFirst, location["streetNumberFirst"] as? String)
        XCTAssertEqual(address.streetNumberLast, location["streetNumberLast"] as? String)
        XCTAssertEqual(address.streetNumberStart, location["streetNumberStart"] as? String)
        XCTAssertEqual(address.streetSuffix, location["streetSuffix"] as? String)
        XCTAssertEqual(address.streetType, location["streetType"] as? String)
        XCTAssertEqual(address.suburb, location["suburb"] as? String)
        XCTAssertEqual(address.unitNumber, location["unitNumber"] as? String)
        XCTAssertEqual(address.unitType, location["unitType"] as? String)
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
